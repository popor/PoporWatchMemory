//
//  PWMViewController.m
//  PoporWatchMemory
//
//  Created by popor on 03/22/2021.
//  Copyright (c) 2021 popor. All rights reserved.
//

#import "RootVC.h"
#import "LeakVC.h"

#import "PoporWatchMemory.h"

@interface RootVC ()

@property (nonatomic, strong) UITextView * infoTV;

@end

@implementation RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    __weak typeof(self) weakSelf = self;
    NSArray * array = @[@"UINavigationController", @"UIEditingOverlayViewController", @"UIInputWindowController",
                        @"UICompatibilityInputViewController", @"UIPredictionViewController",
    ];
    [PoporWatchMemory watchVcIgnoreArray:array warn:^(NSArray<PoporWatchMemoryEntity *> * _Nonnull array, NSMutableString * description) {
        weakSelf.infoTV.text = description;
        
        NSLog(@": %@", description);
    }];
    
    self.title = @"Root";
    
    [self addViews];
}

- (void)addViews {
    UIButton * normalBT;
    UIButton * leakBT;
    {
        UIButton * oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
        oneBT.frame =  CGRectMake(40, 20, 100, 44);
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
        
        normalBT = oneBT;
    }
    {
        UIButton * oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
        oneBT.frame =  CGRectMake(180, 20, 100, 44);
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
        
        leakBT = oneBT;
    }
    
    self.infoTV = ({
        UITextView * oneL = [UITextView new];
        oneL.frame               = CGRectMake(0, 0, 0, 44);
        oneL.backgroundColor     = [UIColor whiteColor]; // ios8 之前
        oneL.font                = [UIFont systemFontOfSize:15];
        oneL.textColor           = [UIColor blackColor];
        oneL.layer.masksToBounds = YES; // ios8 之后 lableLayer 问题
        
        oneL.layer.cornerRadius  = 5;
        oneL.layer.borderColor   = [UIColor lightGrayColor].CGColor;
        oneL.layer.borderWidth   = 1;
        oneL.clipsToBounds       = YES;
        
        [self.view addSubview:oneL];
        oneL;
    });
    
    self.infoTV.frame =
    CGRectMake(10, CGRectGetMaxY(leakBT.frame) +20,
               self.view.frame.size.width - 20,
               self.view.frame.size.height -CGRectGetMaxY(leakBT.frame) -40 - self.navigationController.navigationBar.frame.size.height -40);
    
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
