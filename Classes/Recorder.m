
#import "Recorder.h"
#include "fft.h"

// Wikipedia: In terms of frequency, human voices are roughly in the range of 
// 80 Hz to 1100 Hz (that is, E2 to C6).
const float MIN_FREQ = 50.0f;
const float MAX_FREQ = 1500.0f;

@interface Recorder (Private)
- (void)setUpAudioFormat;
- (UInt32)numPacketsForTime:(Float64)seconds;
- (UInt32)byteSizeForNumPackets:(UInt32)numPackets;
- (void)primeRecordQueueBuffers;
- (void)setUpRecordQueue;
- (void)setUpRecordQueueBuffers;
@end

@implementation Recorder

@synthesize delegate;
@synthesize recording;
@synthesize trackingPitch;
@synthesize recordQueue;
@synthesize bufferByteSize;
@synthesize bufferNumPackets;

static void recordCallback(
	void* inUserData,
	AudioQueueRef inAudioQueue,
	AudioQueueBufferRef inBuffer,
	const AudioTimeStamp* inStartTime,
	UInt32 inNumPackets,
	const AudioStreamPacketDescription* inPacketDesc)
{
	Recorder* recorder = (Recorder*) inUserData;
	if (!recorder.recording)
		return;

	if (inNumPackets > 0)  // we have data
		[recorder recordedBuffer:inBuffer->mAudioData byteSize:inBuffer->mAudioDataByteSize];

	AudioQueueEnqueueBuffer(inAudioQueue, inBuffer, 0, NULL);
}

- (id)init
{
	if ((self = [super init]))
	{
		recording = NO;
		[self setUpAudioFormat];
		[self setUpRecordQueue];
		[self setUpRecordQueueBuffers];
	}
	return self;
}

- (void)setUpAudioFormat
{
	audioFormat.mFormatID         = kAudioFormatLinearPCM;
	audioFormat.mSampleRate       = 11025.0;
	audioFormat.mChannelsPerFrame = 1;
	audioFormat.mBitsPerChannel   = 16;
	audioFormat.mFramesPerPacket  = 1;
	audioFormat.mBytesPerFrame    = audioFormat.mChannelsPerFrame * sizeof(SInt16); 
	audioFormat.mBytesPerPacket   = audioFormat.mBytesPerFrame * audioFormat.mFramesPerPacket;
	audioFormat.mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger 
	                              | kLinearPCMFormatFlagIsPacked;

	bufferNumPackets = 2048;  // must be power of 2 for FFT!
	bufferByteSize = [self byteSizeForNumPackets:bufferNumPackets];

	//NSLog(@"Recorder bufferNumPackets %u", bufferNumPackets);
	//NSLog(@"Recorder bufferByteSize %u", bufferByteSize);
	
	init_fft(bufferNumPackets, audioFormat.mSampleRate);
}

- (UInt32)numPacketsForTime:(Float64)seconds
{
	return (UInt32) (seconds * audioFormat.mSampleRate / audioFormat.mFramesPerPacket);
}

- (UInt32)byteSizeForNumPackets:(UInt32)numPackets
{
	return numPackets * audioFormat.mBytesPerPacket;
}

- (void)setUpRecordQueue
{
	AudioQueueNewInput(
		&audioFormat,
		recordCallback,
		self,                // userData
		CFRunLoopGetMain(),  // run loop
		NULL,                // run loop mode
		0,                   // flags
		&recordQueue);
}

- (void)setUpRecordQueueBuffers
{
	for (int t = 0; t < NUMBER_AUDIO_DATA_BUFFERS; ++t)
	{
		AudioQueueAllocateBuffer(
			recordQueue,
			bufferByteSize,
			&recordQueueBuffers[t]);
	}
}

- (void)primeRecordQueueBuffers
{
	for (int t = 0; t < NUMBER_AUDIO_DATA_BUFFERS; ++t)
	{
		AudioQueueEnqueueBuffer(
			recordQueue,
			recordQueueBuffers[t],
			0,
			NULL);
	}
}

- (void)startRecording
{
	recording = YES;
	[self primeRecordQueueBuffers];
	AudioQueueStart(recordQueue, NULL);
}

- (void)stopRecording
{
	AudioQueueStop(recordQueue, TRUE);
	recording = NO;
}

- (void)recordedBuffer:(UInt8*)buffer byteSize:(UInt32)byteSize
{
	if (trackingPitch)
	{
		float freq = find_pitch(buffer, MIN_FREQ, MAX_FREQ);
		[delegate recordedFreq:freq];
	}
}

- (void)dealloc
{
	done_fft();
	AudioQueueDispose(recordQueue, YES);
	[super dealloc];
}

@end
