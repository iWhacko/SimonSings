
#import "GameModel.h"

/*
 * GameView draws the playing area.
 *
 * We simply draw all the sprites as UIImage objects into our own view.
 *
 * Note: This is actually a child view inside GameView.xib, not the view for 
 * GameView.xib itself (which is a plain UIView).
 */
@interface GameView : UIView
{
	UIImage* backgroundImage;
	UIImage* noteImages[12];
	GameModel* gameModel;
	Note selectedNote;
	Note wrongNote;
}

@property (nonatomic, assign) GameModel* gameModel;
@property (nonatomic, assign) Note selectedNote;
@property (nonatomic, assign) Note wrongNote;

@end
