
#import "SoundEffect.h"

@implementation SoundEffect

+ (id)soundEffectWithContentsOfFile:(NSString*)path
{
	if (path != nil)
		return [[[SoundEffect alloc] initWithContentsOfFile:path] autorelease];
	else
		return nil;
}

- (id)initWithContentsOfFile:(NSString*)path
{
	if (self = [super init])
	{
		FILE* f = fopen([path cStringUsingEncoding:NSASCIIStringEncoding], "rb");

		if (f == NULL)
		{
			[self release];
			self = nil;
			return nil;
		}

		fseek(f, 0L, SEEK_END);
		size = ftell(f);
		fseek(f, 0L, SEEK_SET);
		
		buffer = (UInt8*) malloc(size*sizeof(UInt8));
		if (buffer == NULL)
		{
			fclose(f);
			[self release];
			self = nil;
			return nil;
		}

		if (fread(buffer, size, 1, f) != 1)
		{
			fclose(f);
			[self release];
			self = nil;
			return nil;
		}

		fclose(f);
	}
	return self;
}

- (UInt8*)playBuffer
{
	return buffer + 44;  // skip header
}

- (UInt32)playBufferByteSize
{
	return size - 44;  // without header
}

-(void)dealloc
{
	free(buffer);
	[super dealloc];
}

@end
