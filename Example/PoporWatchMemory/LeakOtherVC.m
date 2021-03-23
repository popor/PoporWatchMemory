//
//  LeakOtherVC.m
//  PoporWatchMemory_Example
//
//  Created by popor on 2021/3/23.
//  Copyright © 2021 popor. All rights reserved.
//

#import "LeakOtherVC.h"

@interface LeakOtherVC ()

@property (nonatomic, strong) NSMutableArray * array;

@end

@implementation LeakOtherVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self test0];
    //[self test1];
}

// 异常
- (void)test0 {
    self.array = [NSMutableArray new];
    [self.array addObject:self];
}

// 正常
- (void)test1 {
    NSMutableArray * array = [NSMutableArray new];
    [array addObject:self];
}

@end
