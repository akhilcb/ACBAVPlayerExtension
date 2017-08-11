//
//  ACBAudioProcessHelper.h
//  ACBAudioPlayer
//
//  Created by Akhil C Balan on 3/3/16.
//  Copyright © 2016 Akhil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^ACBAudioProcessHelperMeteringBlock) (NSArray *iAvgPowerList, BOOL iSuccess);
typedef void (^ACBAudioProcessHelperBufferFetchedBlock) (AVAudioPCMBuffer *audioPCMBuffer, BOOL iSuccess);

@interface ACBAudioProcessHelper : NSObject 

@property (nonatomic, readonly, assign) int numberOfChannels;
@property (nonatomic, weak) AVPlayer *player;
@property (nonatomic, getter=isMeteringEnabled) BOOL meteringEnabled; /* turns level metering on or off. default is off. */

- (float)averagePowerInLinearFormForChannel:(NSUInteger)channelNumber; //returns in average power in linear form. Value is in between 0 to 1.
- (float)averagePowerForChannel:(NSUInteger)channelNumber; /* returns average power in decibels for a given channel */

- (void)averagePowerListWithCallbackBlock:(ACBAudioProcessHelperMeteringBlock)iMeteringCallbackBlock;
- (void)averagePowerListInLinearFormWithCallbackBlock:(ACBAudioProcessHelperMeteringBlock)iMeteringCallbackBlock;
- (void)audioPCMBufferFetchedWithCallbackBlock:(ACBAudioProcessHelperBufferFetchedBlock)iAudioBufferFetchedBlock;

@end
