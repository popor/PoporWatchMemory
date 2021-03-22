//
//  PWMAppDelegate.m
//  PoporWatchMemory
//
//  Created by popor on 03/22/2021.
//  Copyright (c) 2021 popor. All rights reserved.
//

#import "PWMAppDelegate.h"

#import "PoporWatchMemory.h"

@implementation PWMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [PoporWatchMemory watchVcIgnoreArray:@[@"UINavigationController", @"UIEditingOverlayViewController", @"UIInputWindowController"]];
        
    });
    return YES;
}


@end
