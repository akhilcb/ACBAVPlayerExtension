# ACBAVPlayerExtension

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ACBAVPlayer.svg)](https://img.shields.io/cocoapods/v/ACBAVPlayer.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/ACBAVPlayer.svg?style=flat)](https://github.com/akhilcb/ACBAVPlayerExtension)
[![License](https://img.shields.io/cocoapods/l/ACBAVPlayer.svg?style=flat)](http://cocoapods.org/pods/ACBAVPlayer)

An extension on `AVPlayer` which converts it to have all useful features of `AVAudioPlayer` but with streaming support. Also added additional methods to support Audio visualization from `AVPlayer` streaming. This extension adds some missing features to `AVPlayer`. 

This projects shows a simple example on how to use it. ViewController has a `UIProgressView` which displays `averagePower` as a volume meter while streaming an audio through `AVPlayer`. This is very similar to how we would normally use `AVAudioPlayer`, but with some additional methods which makes it easy to display the `averagePower`. `audioPCMBufferFetchedWithCallbackBlock` can be used to fetch `AVAudioPCMBuffer` which can be used for Audio Visualization. Added `stop` method to stop player.


## Demo

<kbd>
<div>
<img src="/ACBAVPlayerExtension/Screenshots/AVPlayerGif1.gif?raw=true" width="466">
</div>
</kbd>

<div><br></div>


## Setup

Carthage or Cocoapods can be used to integrate this to a project. 

### Carthage

```
github "akhilcb/ACBAVPlayerExtension" ~> 2.0

```

### Cocoapods

```
pod 'ACBAVPlayer'

```

## AVPlayer Extension Interface

```
    @property (nonatomic, readonly, assign) int numberOfChannels;
    //stop video
    - (void)stop;
    
    /* metering */
    @property (nonatomic, getter=isMeteringEnabled) BOOL meteringEnabled; /* turns level metering on or off. default is off. */

    - (void)updateMeters; /* call to refresh meter values */
    - (float)peakPowerForChannel:(NSUInteger)channelNumber; /* for peak power in decibels for a given channel. returns average power for now */
    - (float)averagePowerForChannel:(NSUInteger)channelNumber; /* returns average power in decibels for a given channel */
    //use this to repeatedly fetch average power list(in decibels) for all channels in iMeteringCallbackBlock. This block will be executed each time a value is fetched. Index of array is channel number
    - (void)averagePowerListWithCallbackBlock:(ACBAVPlayerMeteringBlock)iMeteringCallbackBlock;
    - (float)averagePowerInLinearFormForChannel:(NSUInteger)channelNumber; //returns in average power in linear form. Value is in between 0 to 1.
    //fetch average power list in linear form(values in between 0 and 1)
    - (void)averagePowerListInLinearFormWithCallbackBlock:(ACBAVPlayerMeteringBlock)iMeteringCallbackBlock;
    //fetch AVAudioPCMBuffer. it has useful methods to manipuate buffers or to display a visualizer
    - (void)audioPCMBufferFetchedWithCallbackBlock:(ACBAVPlayerBufferFetchedBlock)iAudioBufferFetchedBlock;
```

___Note: This is a beta version. There could be some issues(Hopefully minor). Use at your own risk.___


## Usage

```
    self.player = [[AVPlayer alloc] initWithURL:remoteURL];
    self.player.meteringEnabled = true;
    
    [self.player averagePowerListInLinearFormWithCallbackBlock:^(NSArray *iAvgPowerList, BOOL iSuccess) {
        if (iAvgPowerList.count > 0) {
            double power = [iAvgPowerList[0] doubleValue];
            if (iAvgPowerList.count > 1) {
                double secondPower = [iAvgPowerList[1] doubleValue];
                power = (power + secondPower) / 2;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressBar setProgress:(power * 10)];
            });
        }
    }];
```

## Screenshots
<kbd>
<div>
<img src="/ACBAVPlayerExtension/Screenshots/AVPlayerScreen1.png?raw=true" width="466">
</div>
</kbd>

## License

MIT License

Copyright (c) 2017, Akhil C Balan(https://github.com/akhilcb)

All rights reserved.
