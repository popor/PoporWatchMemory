//
//  PWMViewController.m
//  PoporWatchMemory
//
//  Created by popor on 03/22/2021.
//  Copyright (c) 2021 popor. All rights reserved.
//

#import "RootVC.h"
#import "LeakBlockVC.h"
#import "LeakTimerVC.h"
#import "LeakNcVC.h"

#import "PoporWatchMemory.h"

@interface RootVC ()

@property (nonatomic, copy  ) NSArray * titleArray;
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
    
    [PoporWatchMemory watchVcIgnoreArray:array warn:^(NSArray<PoporWatchMemoryEntity *> * _Nonnull array, NSMutableString * _Nonnull description, NSString * _Nonnull className, NSString * _Nonnull pointer) {
        weakSelf.infoTV.text = description;
        NSLog(@": %@ \n\n\n.", description);
    }];
    
    // 或者
    // [PoporWatchMemory watchVcIgnoreArray:array];
    
    self.title = @"Root";
    
    [self addViews];
}

- (void)addViews {
    self.titleArray = @[@"Normal", @"Block", @"Timer", @"Nc", @"Nc Post"];
    UIButton * lastBT;
    CGFloat left         = 10;
    CGFloat gap          = 10;
    CGFloat height       = 40;
    NSInteger maxLineNum = 3;
    CGFloat width        = (self.view.frame.size.width -left*2 -gap*(maxLineNum-1))/maxLineNum;
    
    for (NSInteger i = 0; i<self.titleArray.count; i++) {
        UIButton * oneBT = ({
            UIButton * oneBT = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [oneBT setTitle:[NSString stringWithFormat:@"%@%i", self.titleArray[i], 0] forState:UIControlStateNormal];
            [oneBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [oneBT setBackgroundColor:[UIColor brownColor]];
            oneBT.layer.cornerRadius = 5;
            oneBT.clipsToBounds      = YES;
            
            [self.view addSubview:oneBT];
            
            [oneBT addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
            
            oneBT;
        });
        oneBT.frame =  CGRectMake(left +(width +gap)*(i%maxLineNum), 20 + (height +10)*(i/maxLineNum), width, height);
        
        oneBT.tag = i;
        lastBT = oneBT;
        
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
    CGRectMake(10, CGRectGetMaxY(lastBT.frame) +20,
               self.view.frame.size.width - 20,
               self.view.frame.size.height -CGRectGetMaxY(lastBT.frame) -40 - self.navigationController.navigationBar.frame.size.height -40);
    
}


- (void)btAction:(UIButton *)oneBT {
    UIViewController * vc;
    switch (oneBT.tag) {
        case 0: {
            vc = [UIViewController new];
            vc.view.backgroundColor = UIColor.whiteColor;
            break;
        }
        case 1: {
            vc = [LeakBlockVC new];
            break;
        }
        case 2: {
            vc = [LeakTimerVC new];
            break;
        }
        case 3: {
            vc = [LeakNcVC new];
            break;
        }
        case 4: {
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ncAction) name:@"333" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"333" object:nil];
            return;
        }
        default:
            break;
    }
    
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
        
        vc.title = self.titleArray[oneBT.tag];
        
        NSString * btTitle = oneBT.currentTitle;
        NSString * title0  = self.titleArray[oneBT.tag];
        NSString * title1  = [btTitle substringFromIndex:title0.length];
        NSInteger index    = title1.integerValue +1;
        
        NSString * titleNew  = [NSString stringWithFormat:@"%@%li", self.titleArray[oneBT.tag], index];
        
        [oneBT setTitle:titleNew forState:UIControlStateNormal];
        NSLog(@"%@ : %p", titleNew, vc);
    }
    
}

@end
