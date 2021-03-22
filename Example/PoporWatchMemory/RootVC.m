//
//  PWMViewController.m
//  PoporWatchMemory
//
//  Created by popor on 03/22/2021.
//  Copyright (c) 2021 popor. All rights reserved.
//

#import "RootVC.h"
#import "LeakVC.h"

@interface RootVC ()

@end

@implementation RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Root";

    {
        UIButton * oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
        oneBT.frame =  CGRectMake(40, 100, 100, 44);
        [oneBT setTitle:@"Normal" forState:UIControlStateNormal];
        [oneBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [oneBT setBackgroundColor:[UIColor brownColor]];
        
        // oneBT.titleLabel.font = [UIFont systemFontOfSize:17];
        oneBT.layer.cornerRadius = 5;
        oneBT.layer.borderColor  = [UIColor lightGrayColor].CGColor;
        oneBT.layer.borderWidth  = 1;
        oneBT.clipsToBounds      = YES;
        
        [self.view addSubview:oneBT];
        
        [oneBT addTarget:self action:@selector(btAction_normal) forControlEvents:UIControlEventTouchUpInside];
    }
    {
        UIButton * oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
        oneBT.frame =  CGRectMake(40, 160, 100, 44);
        [oneBT setTitle:@"Leak" forState:UIControlStateNormal];
        [oneBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [oneBT setBackgroundColor:[UIColor brownColor]];
        
        // oneBT.titleLabel.font = [UIFont systemFontOfSize:17];
        oneBT.layer.cornerRadius = 5;
        oneBT.layer.borderColor  = [UIColor lightGrayColor].CGColor;
        oneBT.layer.borderWidth  = 1;
        oneBT.clipsToBounds      = YES;
        
        [self.view addSubview:oneBT];
        
        [oneBT addTarget:self action:@selector(btAction_leak) forControlEvents:UIControlEventTouchUpInside];
    }

}

- (void)btAction_normal {
    UIViewController * vc = [UIViewController new];
    [self.navigationController pushViewController:vc animated:YES];
    
    vc.title = @"Normal";
    vc.view.backgroundColor = UIColor.whiteColor;
}

- (void)btAction_leak {
    
    [self.navigationController pushViewController:[LeakVC new] animated:YES];
}

@end
