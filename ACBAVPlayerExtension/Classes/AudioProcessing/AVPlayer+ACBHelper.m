//
//  AVPlayer+ACBHelper.m
//  ACBAudioPlayer
//
//  Created by Akhil C Balan on 3/3/16.
//  Copyright © 2016 Akhil. All rights reserved.
//

#import "AVPlayer+ACBHelper.h"
#import "ACBAudioProcessHelper.h"
#import <objc/runtime.h>


NSString const *ACBAVPlayerAudioProcessHelperkey = @"ACBAVPlayerAudioProcessHelperkey";

@interface AVPlayer (ACBHelper_Private)

@property (nonatomic, strong) ACBAudioProcessHelper *audioProcessHelper;

@end


@implementation AVPlayer (ACBHelper_Private)

- (void)setAudioProcessHelper:(ACBAudioProcessHelper *)iAudioProcessHelper {
    objc_setAssociatedObject(self, &ACBAVPlayerAudioProcessHelperkey, iAudioProcessHelper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (ACBAudioProcessHelper *)audioProcessHelper {
    return objc_getAssociatedObject(self, &ACBAVPlayerAudioProcessHelperkey);
}

@end


@implementation AVPlayer(ACBHelper)


- (void)stop {
    [self seekToTime:kCMTimeZero];
    [self pause];
    [self replaceCurrentItemWithPlayerItem:nil];
}


- (ACBAudioProcessHelper *)createAudioProcessHelper {
    if (!self.audioProcessHelper) {
        self.audioProcessHelper = [[ACBAudioProcessHelper alloc] init];
        self.audioProcessHelper.player = self;
    }
    return self.audioProcessHelper;
}


- (int)numberOfChannels {
    return self.audioProcessHelper.numberOfChannels;
}


- (void)setMeteringEnabled:(BOOL)iMeteringEnabled {
   
    if (!self.audioProcessHelper) {
        [self createAudioProcessHelper];
    }
    
    [self.audioProcessHelper setMeteringEnabled:iMeteringEnabled];
}


- (BOOL)isMeteringEnabled {
    return self.audioProcessHelper.isMeteringEnabled;
}


- (void)replaceCurrentItemAndUpdateMeteringForPlayerItem:(nullable AVPlayerItem *)item {
    BOOL prevMetering = self.isMeteringEnabled;
    if (prevMetering) {
        self.meteringEnabled = false;
    }
    [self replaceCurrentItemWithPlayerItem:item];
    self.meteringEnabled = prevMetering;
}


- (float)averagePowerForChannel:(NSUInteger)channelNumber {
    
    if (!self.audioProcessHelper) {
        NSLog(@"Enable Metering before calling this method");
        return 0.0f;
    }
    
    return [self.audioProcessHelper averagePowerForChannel:channelNumber];
}


- (float)averagePowerInLinearFormForChannel:(NSUInteger)channelNumber {
    
    if (!self.audioProcessHelper) {
        NSLog(@"Enable Metering before calling this method");
        return 0.0f;
    }
    
    return [self.audioProcessHelper averagePowerInLinearFormForChannel:channelNumber];
}


- (void)averagePowerListWithCallbackBlock:(ACBAVPlayerMeteringBlock)iMeteringCallbackBlock {
    
    if (!self.audioProcessHelper) {
        NSLog(@"Enable Metering before calling this method");
        iMeteringCallbackBlock(nil, false);
    }
    
    [self.audioProcessHelper averagePowerListWithCallbackBlock:^(NSArray *iAvgPowerList, BOOL iSuccess) {
        iMeteringCallbackBlock(iAvgPowerList, iSuccess);
    }];
}


- (void)averagePowerListInLinearFormWithCallbackBlock:(ACBAVPlayerMeteringBlock)iMeteringCallbackBlock {
    
    if (!self.audioProcessHelper) {
        NSLog(@"Enable Metering before calling this method");
        iMeteringCallbackBlock(nil, false);
    }
    
    [self.audioProcessHelper averagePowerListInLinearFormWithCallbackBlock:^(NSArray *iAvgPowerList, BOOL iSuccess) {
        iMeteringCallbackBlock(iAvgPowerList, iSuccess);
    }];
}


- (void)audioPCMBufferFetchedWithCallbackBlock:(ACBAVPlayerBufferFetchedBlock)iAudioBufferFetchedBlock {
    
    if (!self.audioProcessHelper) {
        NSLog(@"Enable Metering before calling this method");
        iAudioBufferFetchedBlock(nil, false);
    }
    
    [self.audioProcessHelper audioPCMBufferFetchedWithCallbackBlock:^(AVAudioPCMBuffer *audioPCMBuffer, BOOL iSuccess) {
        iAudioBufferFetchedBlock(audioPCMBuffer, iSuccess);
    }];
}


- (void)updateMeters {
    //do nothing
}


- (float)peakPowerForChannel:(NSUInteger)channelNumber {
    
    return [self averagePowerForChannel:channelNumber];
}


@end
