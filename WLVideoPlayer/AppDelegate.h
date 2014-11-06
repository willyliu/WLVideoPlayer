//
//  AppDelegate.h
//  WLVideoPlayer
//
//  Created by Willy Liu on 2014/10/28.
//  Copyright (c) 2014年 KKBOX. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WLVideoView;

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet WLVideoView *videoView;
@end

