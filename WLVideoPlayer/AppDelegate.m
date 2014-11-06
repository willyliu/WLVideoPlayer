//
//  AppDelegate.m
//  WLVideoPlayer
//
//  Created by Willy Liu on 2014/10/28.
//  Copyright (c) 2014年 KKBOX. All rights reserved.
//

#import "AppDelegate.h"
#import "WLVideoView.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	[self.videoView setVideoURL:[NSURL URLWithString:@"https://archive.org/download/Windows7WildlifeSampleVideo/Wildlife_512kb.mp4"]];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
