
#import <sys/time.h>
#import "RootViewController.h"
#import "GameViewController.h"
#import "GameView.h"
#import "SoundEffect.h"
#import "TimeBarView.h"

#define MAX_RECORDING_TIME  2000.0  // milliseconds

/*
 * Returns the number of milliseconds that have elapsed since system startup 
 * time as a double.
 */
double milliseconds()
{
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return tv.tv_sec * 1000.0 + tv.tv_usec / 1000.0;
}

@interface GameViewController (Private)
- (void)loadImages;
- (void)loadSounds;
- (SoundEffect*)loadSound:(NSString*)name;
- (void)startTimer;
- (void)stopTimer;
- (void)firstRound;
- (void)nextRound;
- (void)waitForNextRound;
- (void)playNotes;
- (void)startAudio;
- (void)stopAudio;
- (void)waitBeforeRecording;
- (void)recordNotes;
- (void)recordNextNote;
- (void)showPopup:(GameState)newState;
- (void)handlePopup;
@end

@implementation GameViewController

@synthesize rootViewController;
@synthesize gameView;
@synthesize timeBarView;
@synthesize exitButton;
@synthesize roundLabel;
@synthesize highscoreLabel;
@synthesize messageLabel;
@synthesize popupView;
@synthesize gameModel;

void interruptionListenerCallback(void *inUserData, UInt32 interruptionState)
{
	GameViewController* controller = (GameViewController*) inUserData;
	if (interruptionState == kAudioSessionBeginInterruption)
		[controller beginInterruption];
	else if (interruptionState == kAudioSessionEndInterruption)
		[controller endInterruption];
}

- (void)beginInterruption
{
	[self stopAudio];
}

- (void)endInterruption
{
	[self startAudio];
}

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{		
		timer = nil;
		[self loadImages];
		[self loadSounds];
	}
	return self;
}

- (void)viewDidLoad
{
	GameModel* model = [[GameModel alloc] init];
	gameView.gameModel = self.gameModel = model;
	[model release];
	
	timeBarView.maxTime = MAX_RECORDING_TIME;
}

- (void)loadImages
{
	wellDoneImage = [[UIImage imageNamed:@"Well Done.png"] retain];
	gameOverImage = [[UIImage imageNamed:@"Game Over.png"] retain];
	tooSlowImage  = [[UIImage imageNamed:@"Too Slow.png"]  retain];
}

- (void)loadSounds
{
	sounds[0]  = [[self loadSound:@"A"] retain];
	sounds[1]  = [[self loadSound:@"Bb"] retain];
	sounds[2]  = [[self loadSound:@"B"] retain];
	sounds[3]  = [[self loadSound:@"C"] retain];
	sounds[4]  = [[self loadSound:@"Db"] retain];
	sounds[5]  = [[self loadSound:@"D"] retain];
	sounds[6]  = [[self loadSound:@"Eb"] retain];
	sounds[7]  = [[self loadSound:@"E"] retain];
	sounds[8]  = [[self loadSound:@"F"] retain];
	sounds[9]  = [[self loadSound:@"Gb"] retain];
	sounds[10] = [[self loadSound:@"G"] retain];
	sounds[11] = [[self loadSound:@"Ab"] retain];
	
	gameOverSound = [[self loadSound:@"Game Over"] retain];
	listenUpSound = [[self loadSound:@"Listen Up"] retain];
	tooSlowSound  = [[self loadSound:@"Too Slow"] retain];
	wellDoneSound = [[self loadSound:@"Well Done"] retain];
	yourTurnSound = [[self loadSound:@"Your Turn"] retain];
}

- (SoundEffect*)loadSound:(NSString*)name
{
	return [[[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"wav"]] autorelease];
}

/*
 * Called when user switches from Intro screen to the Game screen.
 */
- (void)initController:(GameMode)gameMode
{
	popupView.hidden = YES;
	[gameModel initModel:gameMode];
	[self startAudio];
	[self startTimer];
	[self firstRound];
}

/*
 * Called at the beginning of a new game.
 */
- (void)firstRound
{
	[gameModel initGame];
	[self nextRound];
}

/*
 * Called at the beginning of each new round.
 */
- (void)nextRound
{
	[gameModel initRound];

	waitTime = milliseconds() + 1000.0;  // wait one second

	roundLabel.text = [NSString stringWithFormat:@"Round: %d", gameModel.roundCount];
	highscoreLabel.text = [NSString stringWithFormat:@"Hiscore: %d", [gameModel highscore]];
	messageLabel.text = @"Listen carefully...";

	gameView.selectedNote = -1;
	gameView.wrongNote = -1;
	[gameView setNeedsDisplay];

	timeBarView.timeElapsed = 0;
	[timeBarView setNeedsDisplay];
		
	[player playSoundEffect:listenUpSound];
}

/*
 * Called when the user clicks the "Exit" button.
 */
- (IBAction)exitGame
{
	[self stopTimer];
	[self stopAudio];
	[rootViewController showIntro:self];
}

/*
 * Starts the timer loop.
 */
- (void)startTimer
{
	timer = [NSTimer scheduledTimerWithTimeInterval: 0.050  // 50 ms
											 target: self
										   selector: @selector(handleTimer:)
										   userInfo: nil
											repeats: YES];
}

/*
 * Kills the timer loop.
 */
- (void)stopTimer
{
	if (timer != nil && [timer isValid])
	{
		[timer invalidate];
		timer = nil;
	}
}

/*
 * The timer loop. It runs continuously while the Game screen is active.
 * This is where we handle animations and user interface delays.
 */
- (void)handleTimer:(NSTimer*)timer
{
	switch (gameModel.state)
	{
		case STATE_WAITING:    [self waitForNextRound]; break;
		case STATE_PLAYING:    [self playNotes]; break;
		case STATE_RECORDING1: [self waitBeforeRecording]; break;
		case STATE_RECORDING2: [self recordNotes]; break;
		case STATE_WELL_DONE:  [self handlePopup]; break;
		case STATE_GAME_OVER:  [self handlePopup]; break;
		case STATE_TOO_SLOW:   [self handlePopup]; break;
	}
}

/*
 * User interface delay at the beginning of a new round.
 */
- (void)waitForNextRound
{
	double now = milliseconds();
	if (now >= waitTime)
	{
		gameModel.state = STATE_PLAYING;
		waitTime = now;
	}
}

/*
 * Plays the notes for this round.
 */
- (void)playNotes
{
	double now = milliseconds();
	if (now >= waitTime)
	{
		Note note = [gameModel getNextPlayNote];

		gameView.selectedNote = note;
		gameView.wrongNote = -1;
		[gameView setNeedsDisplay];

		if (note == -1)  // no more notes
		{
			gameModel.state = STATE_RECORDING1;
			waitTime = now + 1000.0;

			[player playSoundEffect:yourTurnSound];
		}
		else
		{
			[player playSoundEffect:sounds[note]];

			waitTime = now + 1500.0;  // play each note for 1.5 seconds
			messageLabel.text = [NSString stringWithFormat:@"Listen carefully... (%d of %d)", gameModel.playCount, gameModel.roundCount];

			//NSLog(@"Playing: %d", note);
		}
	}
}

/*
 * Starts recording from the microphone. Also starts the audio player.
 */
- (void)startAudio
{	
	if (recorder == nil)  // should always be the case
	{
		AudioSessionInitialize(
			NULL,
			NULL,
			interruptionListenerCallback,
			self
			);

		UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
		AudioSessionSetProperty(
			kAudioSessionProperty_AudioCategory,
			sizeof(sessionCategory),
			&sessionCategory
			);

		AudioSessionSetActive(true);

		player = [[Player alloc] init];
		[player startPlaying];
		
		recorder = [[Recorder alloc] init];
		recorder.delegate = self;
		[recorder startRecording];
	}
}

/*
 * Stops recording from the microphone. Also stops the audio player.
 */
- (void)stopAudio
{
	if (recorder != nil)
	{
		[recorder stopRecording];
		[recorder release];
		recorder = nil;

		[player stopPlaying];
		[player release];
		player = nil;

		AudioSessionSetActive(false);
	}
}

/*
 * Timer callback. Listens to the user singing/humming/whistling the notes.
 */
- (void)waitBeforeRecording
{
	double now = milliseconds();
	if (now >= waitTime)
	{
		gameView.selectedNote = -1;
		gameView.wrongNote = -1;
		[gameView setNeedsDisplay];

		gameModel.state = STATE_RECORDING2;
		recorder.trackingPitch = YES;
		[self recordNextNote];
	}
}

/*
 * Timer callback. Listens to the user singing/humming/whistling the notes.
 */
- (void)recordNotes
{
	double now = milliseconds();

	timeBarView.timeElapsed = now - recordingStartedTime;
	[timeBarView setNeedsDisplay];
	
	if (detectedNote == matchNote)
	{
		gameModel.state = STATE_RECORDING1;
		recorder.trackingPitch = NO;
		waitTime = now + 500.0;
		
		gameView.selectedNote = matchNote;
		gameView.wrongNote = -1;
		[gameView setNeedsDisplay];
	}
	else if (now - recordingStartedTime > MAX_RECORDING_TIME)
	{
		recorder.trackingPitch = NO;

		if (detectedNote != -1)  // wrong note
			[self showPopup:STATE_GAME_OVER];
		else
			[self showPopup:STATE_TOO_SLOW];
	}
	else  // wrong note
	{
		gameView.selectedNote = -1;
		gameView.wrongNote = detectedNote;
		[gameView setNeedsDisplay];
	}
}

/*
 * Sets up the next note for recording.
 */
- (void)recordNextNote
{
	matchNote = [gameModel getNextRecordNote];

	if (matchNote == -1)  // all notes done
	{
		messageLabel.text = [NSString stringWithFormat:@"Your turn! (%d of %d)", gameModel.roundCount, gameModel.roundCount];
		recorder.trackingPitch = NO;
		[self showPopup:STATE_WELL_DONE];
		return;
	}

	recordingStartedTime = milliseconds();
	detectedNote = -1;
	detectedFreq = -1;
	deltaFreq = 0.0f;

	messageLabel.text = [NSString stringWithFormat:@"Your turn! (%d of %d)", gameModel.recordCount, gameModel.roundCount];
}

/*
 * Callback from Recorder. This happens in the main thread!
 */
- (void)recordedFreq:(float)freq;
{
	if (gameModel.state == STATE_RECORDING2)
	{
		detectedNote = -1;
		detectedFreq = freq;
		deltaFreq = 0.0f;

		if (freq > 100.0f)  // to avoid environmental noise
		{
			double toneStep = pow(2.0, 1.0/12.0);
			double baseFreq = 440.0;
			
			int noteIndex = (int) round(log(freq/baseFreq) / log(toneStep));
			detectedNote = (120 + noteIndex) % 12;
		}

		// Note: we check in the timer callback whether the detected note
		// is the correct one. Because the timer callback runs much faster
		// than the recorder callback, this won't cause any timing issues.
	}
}

/*
 * Shows the pop-up box.
 */
- (void)showPopup:(GameState)newState
{
	gameModel.state = newState;
	waitTime = milliseconds() + 1500.0;
	blink = YES;
	popupVisible = NO;

	switch (newState)
	{
		case STATE_WELL_DONE: popupView.image = wellDoneImage; break;
		case STATE_GAME_OVER: popupView.image = gameOverImage; break;
		case STATE_TOO_SLOW:  popupView.image = tooSlowImage;  break;
	}

	popupView.hidden = NO;
	popupView.transform = CGAffineTransformMakeScale(0.5, 0.5);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
	popupView.transform = CGAffineTransformMakeScale(1.0, 1.0);
	[UIView commitAnimations];
	
	switch (newState)
	{
		case STATE_WELL_DONE: [player playSoundEffect:wellDoneSound]; break;
		case STATE_GAME_OVER: [player playSoundEffect:gameOverSound]; break;
		case STATE_TOO_SLOW:  [player playSoundEffect:tooSlowSound];  break;
	}
}

/*
 * Called when the pop-up box has grown to its full size.
 */
- (void)growAnimationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
	popupVisible = YES;
}

/*
 * Blinks the "tap to continue" text after the end of a round/at game over.
 */
- (void)handlePopup
{
	double now = milliseconds();
	if (now >= waitTime)
	{
		if (blink)
			messageLabel.text = @"Tap to continue";
		else
			messageLabel.text = @"";

		waitTime = now + 250.0;
		blink = !blink;
	}
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	switch (gameModel.state)
	{
		case STATE_WELL_DONE:
			if (popupVisible)
			{
				popupView.hidden = YES;
				[self nextRound];
			}
			return;

		case STATE_GAME_OVER:
		case STATE_TOO_SLOW:
			if (popupVisible)
			{
				popupView.hidden = YES;
				[self firstRound];
			}
			return;

#if TARGET_IPHONE_SIMULATOR 
		case STATE_RECORDING2:  // just for testing!
		{
			UITouch* touch = [touches anyObject];
			CGPoint location = [touch locationInView:gameView];

			if (location.x < 160)     // tap on left side of screen for success
				[self recordNextNote];
			else
				[self showPopup:STATE_GAME_OVER];  // on right side for failure
				
			return;
		}
#endif
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc
{
	[self stopTimer];
	[self stopAudio];

	[gameModel release];

	[gameView release];
	[timeBarView release];
	[exitButton release];
	[roundLabel release];
	[highscoreLabel release];
	[messageLabel release];
	[popupView release];

	[wellDoneImage release];
	[gameOverImage release];
	[tooSlowImage release];

	for (int t = 0; t < 12; ++t)
		[sounds[t] release];
	
	[gameOverSound release];
	[listenUpSound release];
	[tooSlowSound release];
	[wellDoneSound release];
	[yourTurnSound release];

	[super dealloc];
}

@end
