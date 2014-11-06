//
//  WLVideoView.h
//  WLVideoPlayer
//
//  Created by Willy Liu on 2014/10/28.
//  Copyright (c) 2014年 KKBOX. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@class WLVideoView;

@protocol WLVideoViewDelegate <NSObject>
- (void)videoViewOnReadyToPlay:(WLVideoView *)inVideoView;
- (void)videoViewDidFinishPlaying:(WLVideoView *)inVideoView;
- (void)videoView:(WLVideoView *)inVideoView playingDidFailWithError:(NSError *)inError;
- (void)videoViewDidClick:(WLVideoView *)inVideoView;
@end

@interface WLVideoView : NSView
@property (nonatomic, readonly, strong) AVPlayer* player;
@property (nonatomic, readonly, strong) AVPlayerLayer* playerLayer;
@property (nonatomic, retain) NSURL* videoURL;
@property (nonatomic, assign) BOOL autoStartPlaying;	// default to YES
@property (nonatomic, assign) id<WLVideoViewDelegate> delegate;
- (void) play;
@end