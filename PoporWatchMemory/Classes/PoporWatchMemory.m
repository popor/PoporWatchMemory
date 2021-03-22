//
//  PoporWatchMemory.m
//  PoporWatchMemory
//
//  Created by popor on 2021/3/20.
//  Copyright © 2021 popor. All rights reserved.
//

#import "PoporWatchMemory.h"
#import "UIViewController+PoporWatchMemory.h"

#import <objc/runtime.h>

static NSMutableDictionary * VcPointerDic;   // 指针地址Class
static NSArray             * VcIgnoreArray;
static PoporWatchMemoryBlock WarmBlock;

@implementation PoporWatchMemoryEntity @end

@implementation PoporWatchMemory

+ (void)watchVcIgnoreArray:(NSArray * _Nullable)array {
    [self watchVcIgnoreArray:array warn:nil];
}

+ (void)watchVcIgnoreArray:(NSArray * _Nullable)array warn:(PoporWatchMemoryBlock _Nullable)warmBlock {
    {
        VcIgnoreArray = array;
        WarmBlock     = warmBlock;
        // 暂且不考虑清除之前记录情况.
        // NSArray * keyArray = VcPointerDic.allKeys;
        // for (NSString * pointer in keyArray) {
        //     NSString * className = VcPointerDic[pointer];
        //     if ([array containsObject:className]) {
        //         [VcPointerDic removeObjectForKey:pointer];
        //     }
        // }
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self watch_VC];
    });
    
}

+ (void)watch_VC {
    VcPointerDic = [NSMutableDictionary new];
    
    Class class  = [UIViewController class];
    /*
     @"v@:"   意思就是这已是一个void类型的方法，没有参数传入。
     @"i@:"   就是说这是一个int类型的方法，没有参数传入。
     @"i@:@"  就是说这是一个int类型的方法，又一个参数传入。
     */
    {
        SEL originSEL  = @selector(viewDidLoad);
        SEL swizzleSEL = @selector(viewDidLoad_watchMemory);
        class_addMethod(class, swizzleSEL, class_getMethodImplementation([self class], swizzleSEL), "v@");
        
        [self class:class oldSelector:originSEL newSelector:swizzleSEL];
    }
    
    {
        SEL originSEL  = @selector(viewDidDisappear:);
        SEL swizzleSEL = @selector(viewDidDisappear_watchMemory:);
        class_addMethod(class, swizzleSEL, class_getMethodImplementation([self class], swizzleSEL), "v@:@");
        
        [self class:class oldSelector:originSEL newSelector:swizzleSEL];
    }
}

- (void)viewDidLoad_watchMemory {
    [self viewDidLoad_watchMemory];
    
    //NSLog(@"监听 VC 加载");
    NSString * pointer   = [NSString stringWithFormat:@"%p", self];
    NSString * className = NSStringFromClass(self.class);
    if ([PoporWatchMemory isIgnoreWatchVCName:className]) {
        return;
    }
    
    VcPointerDic[pointer] = NSStringFromClass(self.class);
}

- (void)viewDidDisappear_watchMemory:(BOOL)animated {
    [self viewDidDisappear_watchMemory:animated];
    
    NSString * pointer   = [NSString stringWithFormat:@"%p", self];
    NSString * className = NSStringFromClass(self.class);
    if ([PoporWatchMemory isIgnoreWatchVCName:className]) {
        return;
    }
    
    UIViewController * vc = (UIViewController *)self;
    if (vc.isWillDeallocWhenDisappear_PoporWatchMemory) {
        __weak typeof(vc) weakVC = vc;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakVC) {
                [PoporWatchMemory checkDic:VcPointerDic className:className pointer:pointer];
            } else {
                [VcPointerDic removeObjectForKey:pointer]; //NSLog(@"✅[%@] 析构", VcPointerDic[pointer]);
            }
        });
    }
}

+ (BOOL)isIgnoreWatchVCName:(NSString *)className {
    if ([VcIgnoreArray containsObject:className]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - tool
+ (void)checkDic:(NSMutableDictionary *)dic className:(NSString *)className pointer:(NSString *)pointer {
    NSMutableString * desc = [NSMutableString new];
    [desc appendFormat:@"❌❌\n[%@]异常, 地址: %@, 剩余的vc总数: %li", className, pointer, dic.allKeys.count];
    
    NSMutableArray * array = [NSMutableArray new];
    NSArray * keyArray = dic.allKeys;
    for (NSString * pointer in keyArray) {
        PoporWatchMemoryEntity * entity = [PoporWatchMemoryEntity new];
        entity.className = dic[pointer];
        entity.pointer   = pointer;
        
        [array addObject:entity];
    }
    
    NSArray * result = [array sortedArrayUsingComparator:^NSComparisonResult(PoporWatchMemoryEntity * _Nonnull obj1, PoporWatchMemoryEntity * _Nonnull obj2) {
        return [obj1.className compare:obj2.className];
    }];
    for (PoporWatchMemoryEntity * entity in result) {
        if ([entity.pointer isEqualToString:pointer]) {
            [desc appendFormat:@"\n⚠️%@ \t: ⚠️%@", entity.className, entity.pointer];
        } else if([entity.className isEqualToString:className]) {
            [desc appendFormat:@"\n⚠️%@ \t: %@", entity.className, entity.pointer];
        } else {
            [desc appendFormat:@"\n%@ \t: %@", entity.className, entity.pointer];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (WarmBlock) {
            WarmBlock(result, desc);
        }
    });
}


// 交换 NSObject 方法
+ (void)class:(Class)class oldSelector:(SEL _Nonnull)originalSelector newSelector:(SEL _Nonnull)swizzledSelector
{
    if (!class || !originalSelector || !swizzledSelector) {
        NSLog(@"交换方法失败! %s", __func__);
        return;
    }
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector); //原有方法
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector); //替换原有方法的新方法
    
    if (!originalMethod || !swizzledMethod) {
        NSLog(@"交换方法失败! %s", __func__);
        return;
    }
    
    //先尝试給源SEL添加IMP，这里是为了避免源SEL没有实现IMP的情况
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {//添加成功：说明源SEL没有实现IMP，将源SEL的IMP替换到交换SEL的IMP
        class_replaceMethod(class,swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {//添加失败：说明源SEL已经有IMP，直接将两个SEL的IMP交换即可
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
