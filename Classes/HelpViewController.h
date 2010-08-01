
@interface HelpViewController : UIViewController
{
	RootViewController* rootViewController;
	UIButton* backButton;
}

@property (nonatomic, assign) RootViewController* rootViewController;
@property (nonatomic, retain) IBOutlet UIButton* backButton;	

- (IBAction)goBack;

@end
