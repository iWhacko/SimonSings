
#import "GameView.h"
#import "GameModel.h"

@interface GameView (Private)
- (void)loadImages;
- (void)freeImages;
@end

static CGPoint noteCoords[12] =
{
	{ 242, 216 },  // NOTE_A
	{  44, 163 },  // NOTE_B_FLAT
	{ 189, 309 },  // NOTE_B
	{ 136, 108 },  // NOTE_C
	{  82, 308 },  // NOTE_D_FLAT
	{ 228, 163 },  // NOTE_D
	{  30, 216 },  // NOTE_E_FLAT
	{ 228, 269 },  // NOTE_E
	{  82, 123 },  // NOTE_F
	{ 135, 324 },  // NOTE_G_FLAT
	{ 189, 123 },  // NOTE_G
	{  44, 269 },  // NOTE_A_FLAT
};

@implementation GameView

@synthesize gameModel;
@synthesize selectedNote;
@synthesize wrongNote;

- (id)initWithCoder:(NSCoder*)coder
{
	if (self = [super initWithCoder:coder])
	{
		[self loadImages];
		selectedNote = -1;
		wrongNote = -1;
	}
	return self;
}

- (void)loadImages
{
	backgroundImage = [[UIImage imageNamed:@"Background.png"] retain];
	
	noteImages[NOTE_A]      = [[UIImage imageNamed:@"A Selected.png"] retain];
	noteImages[NOTE_B_FLAT] = [[UIImage imageNamed:@"B Flat Selected.png"] retain];
	noteImages[NOTE_B]      = [[UIImage imageNamed:@"B Selected.png"] retain];
	noteImages[NOTE_C]      = [[UIImage imageNamed:@"C Selected.png"] retain];
	noteImages[NOTE_D_FLAT] = [[UIImage imageNamed:@"C Sharp Selected.png"] retain];
	noteImages[NOTE_D]      = [[UIImage imageNamed:@"D Selected.png"] retain];
	noteImages[NOTE_E_FLAT] = [[UIImage imageNamed:@"E Flat Selected.png"] retain];
	noteImages[NOTE_E]      = [[UIImage imageNamed:@"E Selected.png"] retain];
	noteImages[NOTE_F]      = [[UIImage imageNamed:@"F Selected.png"] retain];
	noteImages[NOTE_G_FLAT] = [[UIImage imageNamed:@"F Sharp Selected.png"] retain];
	noteImages[NOTE_G]      = [[UIImage imageNamed:@"G Selected.png"] retain];
	noteImages[NOTE_A_FLAT] = [[UIImage imageNamed:@"A Flat Selected.png"] retain];
}

- (void)freeImages
{
	[backgroundImage release];
	
	for (int t = 0; t < 12; ++t)
		[noteImages[t] release];
}

- (void)drawRect:(CGRect)rect
{	
	[backgroundImage drawAtPoint:(CGPointMake(0.0, 0.0))];
	
	if (selectedNote != -1)
		[noteImages[selectedNote] drawAtPoint:noteCoords[selectedNote]];
	else if (wrongNote != -1)
		[noteImages[wrongNote] drawAtPoint:noteCoords[wrongNote] blendMode:kCGBlendModeNormal alpha:0.4f];
}

- (void)dealloc
{
	[self freeImages];
	[super dealloc];
}

@end
