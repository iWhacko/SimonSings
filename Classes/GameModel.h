
/* The different notes we can play. */
typedef enum
{
	NOTE_A      = 0,
	NOTE_B_FLAT = 1,
	NOTE_B      = 2,
	NOTE_C      = 3,
	NOTE_D_FLAT = 4,
	NOTE_D      = 5,
	NOTE_E_FLAT = 6,
	NOTE_E      = 7,
	NOTE_F      = 8,
	NOTE_G_FLAT = 9,
	NOTE_G      = 10,
	NOTE_A_FLAT = 11,
}
Note;

/* The difficulty levels. */
typedef enum
{
	GAME_MODE_EASY = 0,   // 3 notes (C, E, G)
	GAME_MODE_MEDIUM,     // 6 notes (C, D, E, F, G, A)
	GAME_MODE_HARD,       // 12 notes (chromatic scale)
}
GameMode;

/* Possible states for the game. */
typedef enum
{
	STATE_WAITING = 0,     // small pause between rounds
	STATE_PLAYING,         // we're playing notes
	STATE_RECORDING1,      // short delay before recording next note
	STATE_RECORDING2,      // we're listening to the user
	STATE_WELL_DONE,       // round successfully completed
	STATE_GAME_OVER,       // player sang a bad note
	STATE_TOO_SLOW,        // player didn't sing correct note quickly enough 
}
GameState;

/* The number of notes that we precalculate. This should be plenty. :-) */
#define MAX_ROUNDS  999

/*
 * The data model for the game.
 */
@interface GameModel : NSObject
{
	// Whether the players are humans or computer-controlled.
	GameMode gameMode;

	// How many rounds have been played so far. The round count is also the
	// number of notes we play in each round.
	int roundCount;

	// Highest number of rounds reached since starting the game.
	int highscores[3];
	
	// The current state of the game.
	GameState state;
	
	// We precalculate the notes that we will play in each round.
	Note notes[MAX_ROUNDS];
	
	// How many notes we already played in this round.
	int playCount;
	
	// How many (good) notes we already recorded in this round.
	int recordCount;
}

@property (nonatomic, assign) int roundCount;
@property (nonatomic, assign, readonly) int playCount;
@property (nonatomic, assign, readonly) int recordCount;
@property (nonatomic, assign) GameMode gameMode;
@property (nonatomic, assign) GameState state;

- (void)initModel:(GameMode)gameMode;
- (void)initGame;
- (void)initRound;
- (Note)getNextPlayNote;
- (Note)getNextRecordNote;
- (int)highscore;
- (void)exitGame;

@end
