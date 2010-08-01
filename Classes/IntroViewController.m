
#import "RootViewController.h"
#import "IntroViewController.h"
#import "GameModel.h"

@implementation IntroViewController

@synthesize rootViewController;
@synthesize easyButton;
@synthesize mediumButton;
@synthesize hardButton;
@synthesize helpButton;

- (IBAction)startEasy
{
	[rootViewController startGame:self inMode:GAME_MODE_EASY];
}

- (IBAction)startMedium
{
	[rootViewController startGame:self inMode:GAME_MODE_MEDIUM];
}

- (IBAction)startHard
{
	[rootViewController startGame:self inMode:GAME_MODE_HARD];
}

- (IBAction)showHelp
{
	[rootViewController showHelp:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc
{
	[easyButton release];
	[mediumButton release];
	[hardButton release];
	[helpButton release];
	[super dealloc];
}

@end
