
#import "RootViewController.h"
#import "HelpViewController.h"

@implementation HelpViewController

@synthesize rootViewController;
@synthesize backButton;

- (IBAction)goBack
{
	[rootViewController showIntro:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc
{
	[backButton release];
	[super dealloc];
}

@end
