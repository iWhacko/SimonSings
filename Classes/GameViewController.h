
#import "GameModel.h"
#import "Player.h"
#import "Recorder.h"

@class RootViewController;
@class GameView;
@class TimeBarView;
@class SoundEffect;

/*
 * The controller performs most of the game logic. Here we also handle the 
 * touches on GameView.
 */
@interface GameViewController : UIViewController <RecorderDelegate>
{
	RootViewController* rootViewController;

	GameView* gameView;	
	TimeBarView* timeBarView;	
	UIButton* exitButton;
	UILabel* roundLabel;
	UILabel* highscoreLabel;
	UILabel* messageLabel;
	UIImageView* popupView;

	UIImage* wellDoneImage;
	UIImage* gameOverImage;
	UIImage* tooSlowImage;

	GameModel* gameModel;         // we own the model
	Player* player;
	Recorder* recorder;

	NSTimer* timer;               // runs the animation loop
	double waitTime;              // for animations and delays
	BOOL blink;                   // for the "tap to continue" text
	BOOL popupVisible;            // YES if the popup has zoomed in
	double recordingStartedTime;  // for timing the user
	Note matchNote;               // the note ther player is supposed to match
	Note detectedNote;            // the note we detected (or -1 if no note)
	float detectedFreq;           // the frequency we detected
	float deltaFreq;              // for calculating how sharp/flat user is

	SoundEffect* sounds[12];
	SoundEffect* gameOverSound;
	SoundEffect* listenUpSound;
	SoundEffect* tooSlowSound;
	SoundEffect* wellDoneSound;
	SoundEffect* yourTurnSound;
}

@property (nonatomic, assign) RootViewController* rootViewController;
@property (nonatomic, retain) IBOutlet GameView* gameView;	
@property (nonatomic, retain) IBOutlet TimeBarView* timeBarView;	
@property (nonatomic, retain) IBOutlet UIButton* exitButton;	
@property (nonatomic, retain) IBOutlet UILabel* roundLabel;
@property (nonatomic, retain) IBOutlet UILabel* highscoreLabel;
@property (nonatomic, retain) IBOutlet UILabel* messageLabel;
@property (nonatomic, retain) IBOutlet UIImageView* popupView;
@property (nonatomic, retain) GameModel* gameModel;

- (void)initController:(GameMode)gameMode;
- (IBAction)exitGame;
- (void)beginInterruption;
- (void)endInterruption;

@end
