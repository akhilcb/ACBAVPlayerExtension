//
//  ViewController.m
//  ACBAVPlayerExtension
//
//  Created by Akhil on 8/10/17.
//  Copyright © 2017 akhil. All rights reserved.
//

#import "ViewController.h"
#import "AVPlayer+ACBHelper.h"
#import <AVFoundation/AVFoundation.h>


@interface ViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, weak) IBOutlet UIProgressView *progressBar;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *firstUrl;
@property (nonatomic, strong) NSString *secondUrl;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.progressBar.progress = 0.0;
    self.firstUrl = @"https://scontent.cdninstagram.com/hphotos-xfa1/t50.2886-16/11719145_918467924880620_816495633_n.mp4";
    self.secondUrl = @"http://techslides.com/demos/sample-videos/small.mp4";

    self.url = self.firstUrl;
    [self setupPlayer];
}


- (void)itemDidFinishPlaying:(NSNotification *)notification {
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
}


- (void)setupPlayer {
    NSURL *audioURL = [NSURL URLWithString:self.url];
    
    if (self.player) {
        [self.player stop];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        self.player = nil;
    }
    
    self.player = [[AVPlayer alloc] initWithURL:audioURL];
    self.player.meteringEnabled = true;
    
    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];

    
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
    
//*********************************
//Similar to an AVAudioPlayer, you can use different methods on AVPlayer while streaming such as:
//Checkout AVPlayer+ACBHelper.h for details
//    [self.player averagePowerForChannel:0];
//    [self.player averagePowerInLinearFormForChannel:0];
//    [self.player peakPowerForChannel:0];
//Additional method which fetches AVAudioPCMBuffer for the stream
//    [self.player audioPCMBufferFetchedWithCallbackBlock:^(AVAudioPCMBuffer *audioPCMBuffer, BOOL iSuccess) {
//    }];
//*********************************
}


- (IBAction)playTapped:(id)sender {
    [self.player play];
}


- (IBAction)stopTapped:(id)sender {
    [self.player stop];
    [self setupPlayer];
    [self.progressBar performSelector:@selector(setProgress:) withObject:@(0.0) afterDelay:0.2f];
}


- (IBAction)pauseTapped:(id)sender {
    [self.player pause];
}


- (IBAction)segmentTapped:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    
    if (segment.selectedSegmentIndex == 0 && self.url != self.firstUrl) {
        self.url = self.firstUrl;
        [self setupPlayer];
        [self.progressBar performSelector:@selector(setProgress:) withObject:@(0.0) afterDelay:0.2f];
    } else if (segment.selectedSegmentIndex == 1 && self.url != self.secondUrl) {
        self.url = self.secondUrl;
        [self setupPlayer];
        [self.progressBar performSelector:@selector(setProgress:) withObject:@(0.0) afterDelay:0.2f];
    }
}


@end
