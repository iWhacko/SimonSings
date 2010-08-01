
#import "GameModel.h"

// The number of notes for each difficulty level.
static int numNotes[3] = { 3, 6, 12 };

// The notes for each difficulty level.
static Note easyNotes[]   = { NOTE_C, NOTE_E, NOTE_G };
static Note mediumNotes[] = { NOTE_C, NOTE_D, NOTE_E, NOTE_F, NOTE_G, NOTE_A };
static Note hardNotes[]   = { NOTE_C, NOTE_D_FLAT, NOTE_D, NOTE_E_FLAT, NOTE_E, 
                              NOTE_F, NOTE_G_FLAT, NOTE_G, NOTE_A_FLAT, NOTE_A, 
                              NOTE_B_FLAT, NOTE_B };

@implementation GameModel

@synthesize roundCount;
@synthesize playCount;
@synthesize recordCount;
@synthesize gameMode;
@synthesize state;

- (id)init
{
	if ((self = [super init]))
	{
		highscores[GAME_MODE_EASY]   = 0;
		highscores[GAME_MODE_MEDIUM] = 0;
		highscores[GAME_MODE_HARD]   = 0;
	}
	return self;
}

/*
 * Called when the user goes from the Intro screen to the Game screen.
 */
- (void)initModel:(GameMode)gameMode_
{
	gameMode = gameMode_;
}

/*
 * Called when a new game starts.
 */
- (void)initGame
{
	roundCount = 0;

	srand(time(NULL));
	int last = -1;
	int i;

	for (int t = 0; t < MAX_ROUNDS; ++t)
	{
		do  // find a new note that is different from the previous
		{ 
			i = rand() % numNotes[gameMode];
		}
		while (i == last);
		last = i;

		switch (gameMode)
		{
			case GAME_MODE_EASY:   notes[t] = easyNotes[i];   break;
			case GAME_MODE_MEDIUM: notes[t] = mediumNotes[i]; break;
			case GAME_MODE_HARD:   notes[t] = hardNotes[i];   break;
		}
	}
}

/*
 * Called when a new round starts.
 */
- (void)initRound
{
	if (roundCount > highscores[gameMode])  // update the highscore
		highscores[gameMode] = roundCount;

	++roundCount;
	playCount = 0;
	recordCount = 0;

	state = STATE_WAITING;
}

/*
 * Returns the next note to play or -1 if no more notes left.
 */
- (Note)getNextPlayNote
{
	if (playCount >= roundCount)
		return -1;
	else
		return notes[playCount++];
}

/*
 * Returns the next note to record or -1 if all notes are done.
 */
- (Note)getNextRecordNote
{
	if (recordCount >= roundCount)
		return -1;
	else
		return notes[recordCount++];
}

/*
 * Returns the highscore for the current game mode.
 */
- (int)highscore
{
	return highscores[gameMode];
}

/*
 * For switching back from Game screen to Intro.
 */
- (void)exitGame
{
	// do nothing
}

@end
