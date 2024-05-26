//
//  AVPlayer+ACBHelper.h
//  ACBAudioPlayer
//
//  Created by Akhil C Balan on 3/3/16.
//  Copyright © 2016 Akhil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^ACBAVPlayerMeteringBlock) (NSArray * _Nullable iAvgPowerList, BOOL iSuccess);
typedef void (^ACBAVPlayerBufferFetchedBlock) (AVAudioPCMBuffer * _Nullable audioPCMBuffer, BOOL iSuccess);


@interface AVPlayer(ACBHelper)

@property (nonatomic, readonly, assign) int numberOfChannels;

//stop video
- (void)stop;


/* metering */
@property (nonatomic, getter=isMeteringEnabled) BOOL meteringEnabled; /* turns level metering on or off. default is off. */

- (void)updateMeters; /* call to refresh meter values */ //does nothing for now

- (float)peakPowerForChannel:(NSUInteger)channelNumber; /* for peak power in decibels for a given channel. returns average power for now */
- (float)averagePowerForChannel:(NSUInteger)channelNumber; /* returns average power in decibels for a given channel */


//use this to repeatedly fetch average power list(in decibels) for all channels in iMeteringCallbackBlock. This block will be executed each time a value is fetched. Index of array is channel number
- (void)averagePowerListWithCallbackBlock:(ACBAVPlayerMeteringBlock _Nullable )iMeteringCallbackBlock;

- (float)averagePowerInLinearFormForChannel:(NSUInteger)channelNumber; //returns in average power in linear form. Value is in between 0 to 1.

//fetch average power list in linear form(values in between 0 and 1)
- (void)averagePowerListInLinearFormWithCallbackBlock:(ACBAVPlayerMeteringBlock _Nullable )iMeteringCallbackBlock;

//fetch AVAudioPCMBuffer. it has useful methods to manipuate buffers or to display a visualizer
- (void)audioPCMBufferFetchedWithCallbackBlock:(ACBAVPlayerBufferFetchedBlock _Nullable )iAudioBufferFetchedBlock;

//use this instead of "replaceCurrentItemWithPlayerItem" for metering to work.
- (void)replaceCurrentItemAndUpdateMeteringForPlayerItem:(nullable AVPlayerItem *)item;

@end
