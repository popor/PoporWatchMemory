//
//  LeakTimerVC.m
//  PoporWatchMemory_Example
//
//  Created by 王凯庆 on 2021/3/22.
//  Copyright © 2021 popor. All rights reserved.
//

#import "LeakTimerVC.h"

@interface LeakTimerVC ()

@property (nonatomic, strong) NSTimer * timer;

@end

@implementation LeakTimerVC

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    });
}

- (void)timerAction {
    NSLog(@"%s", __func__);
}



@end
