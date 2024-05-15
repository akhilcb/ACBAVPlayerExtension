//
//  ACBAudioProcessHelper.m
//  ACBAudioPlayer
//
//  Created by Akhil C Balan on 3/3/16.
//  Copyright © 2016 Akhil. All rights reserved.
//

#import "ACBAudioProcessHelper.h"
#import "MYAudioTapProcessor.h"


static void *ACBAVPlayerStatusObserverContext = &ACBAVPlayerStatusObserverContext;

NSString *const kACBAVPlayerCurrentItemKey = @"currentItem";
NSString *const kACBAVPlayerStatusKey = @"status";


@interface ACBAudioProcessHelper () <MYAudioTabProcessorDelegate>

@property (strong, nonatomic) MYAudioTapProcessor *audioTapProcessor;
@property (assign) float averagePower;
@property (strong) NSArray *averagePowerList;
@property (strong) NSArray *averagePowerListInLinearForm;
@property (strong) AVAudioPCMBuffer *audioPCMBuffer;
@property (copy) ACBAudioProcessHelperMeteringBlock meteringBlock;
@property (copy) ACBAudioProcessHelperMeteringBlock meteringBlockInLinearForm;
@property (copy) ACBAudioProcessHelperBufferFetchedBlock audioBufferFetchedBlock;
@property (strong) AVPlayerItem *playerItem;


- (void)setupMetering;

@end


@implementation ACBAudioProcessHelper

- (void)createAudioTapProcessor {
    
    if (!self.audioTapProcessor) {
        AVAssetTrack *firstAudioAssetTrack;
        NSArray *audioTracks = [self.player.currentItem.asset tracksWithMediaType:AVMediaTypeAudio];
        NSLog(@"audioTracks = %@", audioTracks);

        for (AVAssetTrack *assetTrack in self.player.currentItem.asset.tracks) {
            if ([assetTrack.mediaType isEqualToString:AVMediaTypeAudio]) {
                firstAudioAssetTrack = assetTrack;
                break;
            }
        }
        
        if (firstAudioAssetTrack) {
            self.audioTapProcessor = [[MYAudioTapProcessor alloc] initWithAudioAssetTrack:firstAudioAssetTrack];
            self.audioTapProcessor.delegate = self;
        }
    }
}


- (void)setMeteringEnabled:(BOOL)iMeteringEnabled {
    
    if (!self.isMeteringEnabled && iMeteringEnabled) {
        [self setupMetering];
    } else if (self.isMeteringEnabled && !iMeteringEnabled) {
        self.player.currentItem.audioMix = nil;
        [self releaseAudioTapProcessor];
    }
    
    _meteringEnabled = iMeteringEnabled;
}

- (void)releaseAudioTapProcessor {
    
    if (!self.audioTapProcessor) {
        return;
    }

    [self.audioTapProcessor stopProcessing];
    self.audioTapProcessor = nil;
}

- (void)setupMetering {
    
    if (!self.player.currentItem) {
        //wait for currentItem using observer
        [self addCurrentItemObserverForPlayer];
    } else {
        
        [self createAudioTapProcessor];
        
        if (self.audioTapProcessor) {
            
            if (self.player.currentItem.status == AVPlayerStatusReadyToPlay) {
                [self setupAudioMix];
            } else {
                [self addStatusObserverForPlayerItem];
            }
        } else {
            NSLog(@"failed to setup processor");
        }
    }
}


- (void)setupAudioMix {
    // Add audio mix with audio tap processor to current player item.
    AVAudioMix *audioMix = self.audioTapProcessor.audioMix;
    if (audioMix) {
        // Add audio mix with first audio track.
        self.player.currentItem.audioMix = audioMix;
    }
}


#pragma mark - Add/Remove observers

- (void)addCurrentItemObserverForPlayer {
    [self.player addObserver:self
                  forKeyPath:kACBAVPlayerCurrentItemKey
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:ACBAVPlayerStatusObserverContext];
    
}


- (void)addStatusObserverForPlayerItem {
    if (self.player.currentItem) {
        self.playerItem = self.player.currentItem;
        [self.playerItem addObserver:self
                          forKeyPath:kACBAVPlayerStatusKey
                             options:NSKeyValueObservingOptionNew
                             context:ACBAVPlayerStatusObserverContext];
    }
}


- (void)removeCurrentItemObserverFromPlayer {
    [self.player removeObserver:self forKeyPath:kACBAVPlayerCurrentItemKey context:ACBAVPlayerStatusObserverContext];
}


- (void)removeStatusObserverFromPlayerItem {
    
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:kACBAVPlayerStatusKey context:ACBAVPlayerStatusObserverContext];
        self.playerItem = nil;
    }
}


#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString*)path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
    
    if (context == ACBAVPlayerStatusObserverContext) {
        
        if ([path isEqualToString:kACBAVPlayerCurrentItemKey]) {
            
            AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
            
            if (newPlayerItem != (id)[NSNull null]) {
                [self setupMetering];
            }
            
            [self removeCurrentItemObserverFromPlayer];
        } else {
            if (self.playerItem && object == self.playerItem) {
                
                if ([path isEqualToString:kACBAVPlayerStatusKey]) {
                    
                    AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
                    
                    if (status == AVPlayerStatusReadyToPlay) {
                        
                        [self setupAudioMix];
                    }
                    
                    [self removeStatusObserverFromPlayerItem];
                }
            }
        }
    } else {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}


- (void)averagePowerListWithCallbackBlock:(ACBAudioProcessHelperMeteringBlock)iMeteringCallbackBlock {
    self.meteringBlock = iMeteringCallbackBlock;
}


- (void)averagePowerListInLinearFormWithCallbackBlock:(ACBAudioProcessHelperMeteringBlock)iMeteringCallbackBlock {
    self.meteringBlockInLinearForm = iMeteringCallbackBlock;
}


- (void)audioPCMBufferFetchedWithCallbackBlock:(ACBAudioProcessHelperBufferFetchedBlock)iAudioBufferFetchedBlock {
    self.audioBufferFetchedBlock = iAudioBufferFetchedBlock;
}


- (int)numberOfChannels {
    
    if (self.audioTapProcessor) {
        if (self.audioTapProcessor.numberOfChannels == -1) {
            return 0;
        } else {
            return self.audioTapProcessor.numberOfChannels;
        }
    }
    
    return 1;
}


#pragma mark - MYAudioTabProcessorDelegate

- (void)audioTabProcessor:(MYAudioTapProcessor *)audioTabProcessor hasNewLeftChannelValue:(float)leftChannelValue rightChannelValue:(float)rightChannelValue {
    // Update left and right channel volume unit meter.
    
    self.averagePower = (leftChannelValue + rightChannelValue) / 2.0f;
}


- (void)audioTabProcessor:(MYAudioTapProcessor *)audioTabProcessor hasNewChannelVolumeList:(NSArray *)iChannelVolumeList {
    
    self.averagePowerListInLinearForm = iChannelVolumeList;
    self.averagePowerList = [self convertAveragePowerListToDecibelFormat:iChannelVolumeList];
    
    if (self.meteringBlock) {
        self.meteringBlock(self.averagePowerList, true);
    }
    
    if (self.meteringBlockInLinearForm) {
        self.meteringBlockInLinearForm(self.averagePowerListInLinearForm, true);
    }
}


- (void)audioTabProcessor:(MYAudioTapProcessor *)audioTabProcessor didReceiveBuffer:(AVAudioPCMBuffer *)buffer {
    self.audioPCMBuffer = buffer;
    
    if (self.audioBufferFetchedBlock) {
        self.audioBufferFetchedBlock(buffer, true);
    }
}


- (float)averagePowerForChannel:(NSUInteger)channelNumber {
    
    if (channelNumber < self.averagePowerList.count) {
        return [self.averagePowerList[channelNumber] floatValue];
    }
    
    return self.averagePower;
}


- (float)averagePowerInLinearFormForChannel:(NSUInteger)channelNumber {
    
    if (channelNumber < self.averagePowerListInLinearForm.count) {
        return [self.averagePowerListInLinearForm[channelNumber] floatValue] * 2.8f; //temp fix for correcting to match with avaudiorecorder level measured
    }
    
    return self.averagePower * 2.8f;
}


- (NSArray *)convertAveragePowerListToDecibelFormat:(NSArray *)iChannelVolumeList {
    
    NSMutableArray *aDbChannelVolumeList = [NSMutableArray array];
    
    for (NSNumber *aChannelVolume in iChannelVolumeList) {
        float dB = 20 * log10(aChannelVolume.floatValue);
        
        if (aChannelVolume.floatValue <= 0.0f) {
            dB = -160.0f;//set min to -160.0f
        }

        [aDbChannelVolumeList addObject:@(dB)];
    }
    
    return aDbChannelVolumeList;
}

@end
