//
//  LeakVC.m
//  PoporWatchMemory_Example
//
//  Created by popor on 2021/3/22.
//  Copyright © 2021 popor. All rights reserved.
//

#import "LeakVC.h"

typedef void(^LeakVCBlock)(void);

@interface LeakVC ()

@property (nonatomic, copy  ) LeakVCBlock block;

@end

@implementation LeakVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"Leak";
    
    [self addLeakCode];
}

- (void)addLeakCode {
    
    self.block = ^{
        NSLog(@"%@: ", self.title);
    };
}

@end
