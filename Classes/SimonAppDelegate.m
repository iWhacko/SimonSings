
#import "SimonAppDelegate.h"
#import "RootViewController.h"

@implementation SimonAppDelegate

@synthesize window;
@synthesize rootViewController;

- (void)applicationDidFinishLaunching:(UIApplication*)application
{
	RootViewController* viewController = [[RootViewController alloc] init];
	self.rootViewController = viewController;
	[viewController release];

	[window addSubview:[rootViewController view]];		
	[window makeKeyAndVisible];
}

- (void)dealloc
{
	[rootViewController release];
	[window release];
	[super dealloc];
}

@end
