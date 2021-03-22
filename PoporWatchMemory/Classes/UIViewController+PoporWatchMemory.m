//
//  UIViewController+PoporWatchMemory.m
//  PoporWatchMemory
//
//  Created by popor on 2021/3/22.
//

#import "UIViewController+PoporWatchMemory.h"

@implementation UIViewController (PoporWatchMemory)

- (BOOL)isWillDeallocWhenDisappear_PoporWatchMemory {
    if ([self isKindOfClass:[UINavigationController class]]) {
        return NO;
    }
    
    if (self.navigationController) {
        NSArray * vcArray = self.navigationController.viewControllers;
        
        if ([vcArray containsObject:self]) {
            return NO;
        }
        else {
            return YES;
        }
    } else if (self.presentedViewController) {
        return YES;
    }
    
    // 可能是延迟的时候, self.navigationController 和 self.presentedViewController 都为空了.
    return YES;
}

@end
