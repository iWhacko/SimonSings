
#import "RootViewController.h"
#import "IntroViewController.h"
#import "GameViewController.h"
#import "HelpViewController.h"

@interface RootViewController (Private)
- (void)loadIntroViewController;
- (void)loadGameViewController;
- (void)loadHelpViewController;
- (void)fadeBetween:(UIViewController*)oldController and:(UIViewController*)newController;
@end

@implementation RootViewController

@synthesize introViewController;
@synthesize gameViewController;
@synthesize helpViewController;

- (void)viewDidLoad
{
	[self loadIntroViewController];
	[self.view addSubview:introViewController.view];
}

- (void)loadIntroViewController
{
	IntroViewController* viewController = [[IntroViewController alloc] initWithNibName:@"IntroView" bundle:nil];
	viewController.rootViewController = self;
	self.introViewController = viewController;
	[viewController release];
}

- (void)loadGameViewController
{
	GameViewController* viewController = [[GameViewController alloc] initWithNibName:@"GameView" bundle:nil];
	viewController.rootViewController = self;
	self.gameViewController = viewController;
	[viewController release];
}

- (void)loadHelpViewController
{
	HelpViewController* viewController = [[HelpViewController alloc] initWithNibName:@"HelpView" bundle:nil];
	viewController.rootViewController = self;
	self.helpViewController = viewController;
	[viewController release];
}

/*
 * Removes one child view from our view and replaces it by another, 
 * using an animated transition.
 */
- (void)fadeBetween:(UIViewController*)oldController and:(UIViewController*)newController
{
	UIView* oldView = oldController.view;
	UIView* newView = newController.view;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.40];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
	
	[newController viewWillAppear:YES];
	[oldController viewWillDisappear:YES];
	[oldView removeFromSuperview];
	[self.view addSubview:newView];
	[oldController viewDidDisappear:YES];
	[newController viewDidAppear:YES];
	[UIView commitAnimations];
}

/*
 * Returns the app to the Intro screen.
 */
- (void)showIntro:(id)sender
{	
	[self fadeBetween:(UIViewController*)sender and:introViewController];
}

/*
 * Switches to the the Game screen.
 */
- (void)startGame:(id)sender inMode:(GameMode)gameMode
{
	if (gameViewController == nil)      // load on demand
		[self loadGameViewController];

	[self fadeBetween:(UIViewController*)sender and:gameViewController];

	[gameViewController initController:gameMode];
}

/*
 * Switches to the Help screen.
 */
- (void)showHelp:(id)sender
{
	if (helpViewController == nil)      // load on demand
		[self loadHelpViewController];

	[self fadeBetween:(UIViewController*) sender and:helpViewController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc
{
	[introViewController release];
	[helpViewController release];
	[gameViewController release];
	[super dealloc];
}

@end
