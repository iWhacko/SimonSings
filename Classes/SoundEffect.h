
#import <UIKit/UIKit.h>

@interface SoundEffect : NSObject
{
	UInt8* buffer;
	UInt32 size;
}

@property (nonatomic, assign, readonly) UInt8* playBuffer;
@property (nonatomic, assign, readonly) UInt32 playBufferByteSize;

+ (id)soundEffectWithContentsOfFile:(NSString*)path;
- (id)initWithContentsOfFile:(NSString*)path;

@end
