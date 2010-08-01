
#import "TimeBarView.h"

@implementation TimeBarView

@synthesize imageEmpty;
@synthesize imageFull;
@synthesize timeElapsed;
@synthesize maxTime;

- (id)initWithCoder:(NSCoder*)coder
{
	if (self = [super initWithCoder:coder])
	{
		imageEmpty = [UIImage imageNamed:@"Timer Empty.png"];
		imageFull = [UIImage imageNamed:@"Timer Full.png"];
		timeElapsed = 0;
		maxTime = 1.0;
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	if (timeElapsed > 0)
	{
		float width = imageEmpty.size.width;
		float height = imageEmpty.size.height;
		float elapsedPixels = roundf((timeElapsed / maxTime) * width);
		if (elapsedPixels > width)
			elapsedPixels = width;

		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM(context, 0.0, rect.size.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		
		CGRect imageRect;
		CGImageRef imageRef;
		
		if (elapsedPixels < width)
		{
			imageRect = CGRectMake(elapsedPixels, 0.0, width - elapsedPixels, height);
			imageRef = CGImageCreateWithImageInRect(imageEmpty.CGImage, imageRect);
			CGContextDrawImage(context, imageRect, imageRef);
			CGImageRelease(imageRef);
		}

		if (elapsedPixels > 0)
		{
			imageRect = CGRectMake(0.0, 0.0, elapsedPixels, height);
			imageRef = CGImageCreateWithImageInRect(imageFull.CGImage, imageRect);
			CGContextDrawImage(context, imageRect, imageRef);
			CGImageRelease(imageRef);
		}
	}
}

- (void)dealloc
{
	[imageEmpty release];
	[imageFull release];
	[super dealloc];
}

@end
