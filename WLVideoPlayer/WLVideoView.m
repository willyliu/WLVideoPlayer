//
//  WLVideoView.m
//  WLVideoPlayer
//
//  Created by Willy Liu on 2014/10/28.
//  Copyright (c) 2014年 KKBOX. All rights reserved.
//

#import "WLVideoView.h"

static void *WLVideoViewPlayerLayerReadyForDisplay = &WLVideoViewPlayerLayerReadyForDisplay;
static void *WLVideoViewPlayerItemStatusContext = &WLVideoViewPlayerItemStatusContext;

@interface WLVideoView()

- (void)onError:(NSError*)error;
- (void)onReadyToPlay;
- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys;

@end

@implementation WLVideoView

@synthesize player = _player;
@synthesize playerLayer = _playerLayer;
@synthesize videoURL = _videoURL;

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self _init];
	}
	
	return self;
}

- (void)_init
{
	self.wantsLayer = YES;
	_player = [[AVPlayer alloc] init];
	self.autoStartPlaying = YES;
	[self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:WLVideoViewPlayerItemStatusContext];
}

- (void)awakeFromNib
{
	[self _init];
}

- (void) dealloc {
	[self.player pause];
	[self removeObserver:self forKeyPath:@"player.currentItem.status"];
	[self removeObserver:self forKeyPath:@"playerLayer.readyForDisplay"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setVideoURL:(NSURL *)videoURL {
	_videoURL = videoURL;
	
	[self.player pause];
	[self.playerLayer removeFromSuperlayer];
	
	AVURLAsset *asset = [AVAsset assetWithURL:self.videoURL];
	NSArray *assetKeysToLoadAndTest = [NSArray arrayWithObjects:@"playable", @"hasProtectedContent", @"tracks", @"duration", nil];
	[asset loadValuesAsynchronouslyForKeys:assetKeysToLoadAndTest completionHandler:^(void) {
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[self setUpPlaybackOfAsset:asset withKeys:assetKeysToLoadAndTest];
		});
	}];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[self.delegate videoViewDidClick:self];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == WLVideoViewPlayerItemStatusContext) {
		AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
		switch (status) {
			case AVPlayerItemStatusUnknown:
				break;
			case AVPlayerItemStatusReadyToPlay:
				[self onReadyToPlay];
				break;
			case AVPlayerItemStatusFailed:
				[self onError:nil];
				break;
		}
	} else if (context == WLVideoViewPlayerLayerReadyForDisplay) {
		if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue]) {
			self.playerLayer.hidden = NO;
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


#pragma mark - Private

- (void)onError:(NSError*)error {
	// Notify delegate
	[self.delegate videoView:self playingDidFailWithError:error];
}

- (void)onReadyToPlay {
	// Notify delegate
	[self.delegate videoViewOnReadyToPlay:self];	
	if (self.autoStartPlaying) {
		[self play];
	}
}

- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys {
	for (NSString *key in keys) {
		NSError *error = nil;
		if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
			[self onError:error];
			return;
		}
	}
	
	if (!asset.isPlayable || asset.hasProtectedContent) {
		[self onError:nil];
		return;
	}
	
	if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) { // Asset has video tracks
		_playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
		self.playerLayer.frame = self.layer.bounds;
		self.playerLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
		self.playerLayer.hidden = YES;
		[self.layer addSublayer:self.playerLayer];
		[self addObserver:self forKeyPath:@"playerLayer.readyForDisplay" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:WLVideoViewPlayerLayerReadyForDisplay];
	}
	
	// Create a new AVPlayerItem and make it our player's current item.
	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
	[self.player replaceCurrentItemWithPlayerItem:playerItem];
}

#pragma mark - Public

- (void) play {
	[self.player play];
}

#pragma mark - Notification

-(void)itemDidFinishPlaying:(NSNotification *) notification {
	// Will be called when AVPlayer finishes playing playerItem
	[self.delegate videoViewDidFinishPlaying:self];
}

@end
