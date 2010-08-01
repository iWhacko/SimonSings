
@class RootViewController;

/*
 * The Intro screen just contains a few buttons and some static "about" text.
 */
@interface IntroViewController : UIViewController
{
	RootViewController* rootViewController;
	UIButton* easyButton;	
	UIButton* mediumButton;
	UIButton* hardButton;
	UIButton* helpButton;
}

@property (nonatomic, assign) RootViewController* rootViewController;
@property (nonatomic, retain) IBOutlet UIButton* easyButton;	
@property (nonatomic, retain) IBOutlet UIButton* mediumButton;
@property (nonatomic, retain) IBOutlet UIButton* hardButton;
@property (nonatomic, retain) IBOutlet UIButton* helpButton;	

- (IBAction)startEasy;
- (IBAction)startMedium;
- (IBAction)startHard;
- (IBAction)showHelp;

@end
