
/*
 * Draws the timer bar while we're listening to the user.
 */
@interface TimeBarView : UIView
{
	UIImage* imageEmpty;
	UIImage* imageFull;
	double timeElapsed;
	double maxTime;
}

@property (nonatomic, retain) UIImage* imageEmpty;
@property (nonatomic, retain) UIImage* imageFull;
@property (nonatomic, assign) double timeElapsed;
@property (nonatomic, assign) double maxTime;

@end
