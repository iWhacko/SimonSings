
#import "GameModel.h"

@class IntroViewController;
@class GameViewController;
@class HelpViewController;

/*
 * This controller switches between the different screens.
 */
@interface RootViewController : UIViewController
{
	IntroViewController* introViewController;
	GameViewController* gameViewController;
	HelpViewController* helpViewController;
}

@property (nonatomic, retain) IntroViewController* introViewController;
@property (nonatomic, retain) GameViewController* gameViewController;
@property (nonatomic, retain) HelpViewController* helpViewController;

- (void)showIntro:(id)sender;
- (void)startGame:(id)sender inMode:(GameMode)gameMode;
- (void)showHelp:(id)sender;

@end
