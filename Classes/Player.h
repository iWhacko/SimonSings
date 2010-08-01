
#define NUMBER_AUDIO_DATA_BUFFERS  3

@class SoundEffect;

/*
 * Very basic player: we copy the little endian 16-bit stereo WAV data directly
 * into the audio buffers. Player can play only one sound at a time right now.
 */
@interface Player : NSObject
{
	BOOL playing;

	// the relative audio level for the playback audio queue
	Float32 gain;
	
	// the format used for playback
	AudioStreamBasicDescription audioFormat;

	// the audio queue object being used for playback
	AudioQueueRef playQueue;
	
	// the audio queue buffers for the playback audio queue
	AudioQueueBufferRef playQueueBuffers[NUMBER_AUDIO_DATA_BUFFERS];

	// the number of bytes to use in each audio queue buffer
	UInt32 bufferByteSize;

	// the number of audio data packets to read into each audio queue buffer
	UInt32 bufferNumPackets;

	// the buffer with the wave data
	UInt8* playBuffer;
	
	// how many bytes in the wave buffer
	UInt32 playBufferByteSize;

	// the read pointer for the wave buffer
	UInt8* playBufferPtr;
}

@property (assign) BOOL playing;
@property (assign) Float32 gain;	
@property (assign) AudioQueueRef playQueue;
@property (assign) UInt32 bufferByteSize;
@property (assign) UInt32 bufferNumPackets;
@property (assign) UInt8* playBuffer;
@property (assign) UInt32 playBufferByteSize;
@property (assign) UInt8* playBufferPtr;

- (void)startPlaying;
- (void)stopPlaying;
- (void)playBuffer:(UInt8*)buffer size:(UInt32)size;
- (void)playSoundEffect:(SoundEffect*)soundEffect;

@end
