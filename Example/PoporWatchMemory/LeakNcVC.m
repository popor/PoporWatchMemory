//
//  LeakNcVC.m
//  PoporWatchMemory_Example
//
//  Created by 王凯庆 on 2021/3/22.
//  Copyright © 2021 popor. All rights reserved.
//

#import "LeakNcVC.h"

@interface LeakNcVC ()

@end

@implementation LeakNcVC

- (void)dealloc {
    NSLog(@"%s %p", __func__, self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ncAction) name:@"333" object:nil];
    
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame =  CGRectMake(100, 100, 80, 44);
        [button setTitle:@"Post" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor brownColor]];
        
        // button.titleLabel.font = [UIFont systemFontOfSize:17];
        button.layer.cornerRadius = 5;
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.layer.borderWidth = 1;
        button.clipsToBounds = YES;
        
        [self.view addSubview:button];
        
        [button addTarget:self action:@selector(btAction) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)ncAction {
    NSLog(@"%s", __func__);
}

- (void)btAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"333" object:nil];
}

@end
