//
//  LeakVC.m
//  PoporWatchMemory_Example
//
//  Created by popor on 2021/3/22.
//  Copyright © 2021 popor. All rights reserved.
//

#import "LeakBlockVC.h"

typedef void(^LeakVCBlock)(void);

@interface LeakBlockVC ()

@property (nonatomic, copy  ) LeakVCBlock block;

@end

@implementation LeakBlockVC

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self addLeakCode];
}

- (void)addLeakCode {
    
    self.block = ^{
        NSLog(@"%@: ", self.title);
    };
}

@end
