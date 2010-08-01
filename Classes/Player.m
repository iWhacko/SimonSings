
#import "Player.h"
#import "SoundEffect.h"

@interface Player (Private)
- (void)setUpAudioFormat;
- (UInt32)numPacketsForTime:(Float64)seconds;
- (UInt32)byteSizeForNumPackets:(UInt32)numPackets;
- (void)setUpPlayQueue;
- (void)setUpPlayQueueBuffers;
- (void)primePlayQueueBuffers;
@end

@implementation Player

@synthesize playing;
@synthesize gain;
@synthesize playQueue;
@synthesize bufferByteSize;
@synthesize bufferNumPackets;
@synthesize playBuffer;
@synthesize playBufferByteSize;
@synthesize playBufferPtr;

static void playCallback(
	void* inUserData, AudioQueueRef inAudioQueue, AudioQueueBufferRef inBuffer)
{
	Player* player = (Player*) inUserData;
	if (!player.playing)
		return;

	memset(inBuffer->mAudioData, 0, player.bufferByteSize);
	inBuffer->mAudioDataByteSize = player.bufferByteSize;

	if (player.playBuffer != NULL)
	{
		UInt32 count = player.playBuffer + player.playBufferByteSize - player.playBufferPtr;
		if (count > player.bufferByteSize)
			count = player.bufferByteSize;
		else
			player.playBuffer = NULL;  // we're done

		memcpy((UInt8*) inBuffer->mAudioData, player.playBufferPtr, count);
		player.playBufferPtr += count;
	}

	AudioQueueEnqueueBuffer(inAudioQueue, inBuffer, 0, NULL);
}

- (id)init
{
	if ((self = [super init]))
	{
		playing = NO;
		[self setUpAudioFormat];
		[self setUpPlayQueue];
		[self setUpPlayQueueBuffers];
	}
	return self;
}

- (void)setUpAudioFormat
{
	audioFormat.mFormatID         = kAudioFormatLinearPCM;
	audioFormat.mSampleRate       = 44100.0;
	audioFormat.mChannelsPerFrame = 2;
	audioFormat.mBitsPerChannel   = 16;
	audioFormat.mFramesPerPacket  = 1;
	audioFormat.mBytesPerFrame    = audioFormat.mChannelsPerFrame * sizeof(SInt16); 
	audioFormat.mBytesPerPacket   = audioFormat.mBytesPerFrame * audioFormat.mFramesPerPacket;
	audioFormat.mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger 
	                              | kLinearPCMFormatFlagIsPacked; 

	bufferNumPackets = 2048;
	bufferByteSize = [self byteSizeForNumPackets:bufferNumPackets];

	//NSLog(@"Player bufferNumPackets %u", bufferNumPackets);
	//NSLog(@"Player bufferByteSize %u", bufferByteSize);
}

- (UInt32)numPacketsForTime:(Float64)seconds
{
	return (UInt32) (seconds * audioFormat.mSampleRate / audioFormat.mFramesPerPacket);
}

- (UInt32)byteSizeForNumPackets:(UInt32)numPackets
{
	return numPackets * audioFormat.mBytesPerPacket;
}

- (void)setUpPlayQueue
{
	AudioQueueNewOutput(
		&audioFormat,
		playCallback,
		self, 
		NULL,                   // run loop
		kCFRunLoopCommonModes,  // run loop mode
		0,                      // flags
		&playQueue
		);

	[self setGain:1.0];

	AudioQueueSetParameter(
		playQueue,
		kAudioQueueParam_Volume,
		gain
		);
}

- (void)setUpPlayQueueBuffers
{
	for (int t = 0; t < NUMBER_AUDIO_DATA_BUFFERS; ++t)
	{
		AudioQueueAllocateBuffer(
			playQueue,
			bufferByteSize,
			&playQueueBuffers[t]
			);
	}
}

- (void)primePlayQueueBuffers
{
	for (int t = 0; t < NUMBER_AUDIO_DATA_BUFFERS; ++t)
	{
		playCallback(self, playQueue, playQueueBuffers[t]);
	}
}

- (void)startPlaying
{
	playing = YES;
	[self primePlayQueueBuffers];
	AudioQueueStart(playQueue, NULL);
}

- (void)stopPlaying
{
	AudioQueueStop(playQueue, TRUE);
	playing = NO;
}

- (void)playBuffer:(UInt8*)buffer size:(UInt32)size;
{
	playBuffer = buffer;
	playBufferByteSize = size;
	playBufferPtr = playBuffer;
}

- (void)playSoundEffect:(SoundEffect*)soundEffect
{
	[self playBuffer:soundEffect.playBuffer size:soundEffect.playBufferByteSize];
}

- (void)dealloc
{
	AudioQueueDispose(playQueue, YES);
	[super dealloc];
}

@end
