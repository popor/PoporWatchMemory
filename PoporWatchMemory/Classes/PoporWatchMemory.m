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
//#import <malloc/malloc.h>

static NSMutableDictionary * VcPointerDic;   // 指针地址Class
static NSArray             * VcIgnoreArray;
static PoporWatchMemoryBlock WarmBlock;
static BOOL                  UseAtt;

@implementation PoporWatchMemoryEntity @end

@implementation PoporWatchMemory

+ (void)watchVcIgnoreArray:(NSArray * _Nullable)array {
    [self watchVcIgnoreArray:array att:NO warn:nil];
}

+ (void)watchVcIgnoreArray:(NSArray * _Nullable)array att:(BOOL)useAtt warn:(PoporWatchMemoryBlock _Nullable)warmBlock
{
    {
        VcIgnoreArray = array;
        UseAtt        = useAtt;
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
    
    {
        PoporWatchMemoryEntity * entity = [PoporWatchMemoryEntity new];
        entity.className = NSStringFromClass(self.class);
        entity.pointer   = pointer;
        //entity.instanceSize = class_getInstanceSize(self.class);
        
        VcPointerDic[pointer] = entity;
    }
}

- (void)viewDidDisappear_watchMemory:(BOOL)animated {
    [self viewDidDisappear_watchMemory:animated];
    
    NSString * pointer   = [NSString stringWithFormat:@"%p", self];
    NSString * className = NSStringFromClass(self.class);
    
    PoporWatchMemoryEntity * entity = VcPointerDic[pointer];
    if (!entity) {
        return;
    }
    
    UIViewController * vc = (UIViewController *)self;
    //entity.mallocSize = malloc_size((__bridge const void *)self);
    
    if (vc.isWillDeallocWhenDisappear_PoporWatchMemory) {
        __weak typeof(vc) weakVC = vc;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakVC) {
                if (UseAtt) {
                    [PoporWatchMemory checkDic_att:VcPointerDic className:className pointer:pointer];
                } else {
                    [PoporWatchMemory checkDic_str:VcPointerDic className:className pointer:pointer];
                }
            } else {
                [VcPointerDic removeObjectForKey:pointer]; //NSLog(@"✅[%@] 析构", VcPointerDic[pointer]);
            }
        });
    }
}

#pragma mark - tool
+ (BOOL)isIgnoreWatchVCName:(NSString *)className {
    if ([VcIgnoreArray containsObject:className]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)checkDic_att:(NSMutableDictionary *)dic className:(NSString *)className pointer:(NSString *)pointer {
    UIFont  * font        = [UIFont  systemFontOfSize:15];
    UIColor * normalColor = [UIColor blackColor];
    UIColor * warmColor   = [UIColor redColor];
    NSMutableAttributedString * att = [NSMutableAttributedString new];
    
    
    void (^ attPointerBlock)(NSString *, UIColor *) = ^(NSString * string, UIColor * color){
        NSString * editString = [NSString stringWithFormat:@"%-16s", [string UTF8String]];
        [self att:att string:editString font:font color:color];
    };
    void (^ attBlock)(NSString *, UIColor *) = ^(NSString * string, UIColor * color){
        [self att:att string:string font:font color:color];
    };
    
    attBlock([NSString stringWithFormat:@"❌❌ VC数量: %li, 最后位于\n", dic.allKeys.count], normalColor);
    attBlock(pointer, warmColor);
    attBlock(@"   :", normalColor);
    attBlock(className, warmColor);
    
    attBlock([NSString stringWithFormat:@"\n%@", self.lineString], normalColor);
    
    NSArray * originArray = dic.allValues;
    NSArray * result = [originArray sortedArrayUsingComparator:^NSComparisonResult(PoporWatchMemoryEntity * _Nonnull obj1, PoporWatchMemoryEntity * _Nonnull obj2) {
        return [obj1.className compare:obj2.className];
    }];
    
    for (PoporWatchMemoryEntity * entity in result) {
        if ([entity.pointer isEqualToString:pointer]) {
            attBlock(@"\n", normalColor);
            attPointerBlock(entity.pointer, warmColor);
            attBlock(@" : ", normalColor);
            attBlock([NSString stringWithFormat:@"%@ ⚠️", entity.className], warmColor);
        } else if([entity.className isEqualToString:className]) {
            attBlock(@"\n", normalColor);
            attPointerBlock(entity.pointer, normalColor);
            attBlock(@" : ", normalColor);
            attBlock([NSString stringWithFormat:@"%@ ⚠️", entity.className], warmColor);
        } else {
            attBlock(@"\n", normalColor);
            attPointerBlock(entity.pointer, normalColor);
            attBlock(@" : ", normalColor);
            attBlock(entity.className, normalColor);
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (WarmBlock) {
            WarmBlock(result, att, className, pointer);
        } else {
            NSLog(@"\n%@\n\n%@\n\n%@", self.lineString, att.string, self.lineString);
        }
    });
}

+ (void)checkDic_str:(NSMutableDictionary *)dic className:(NSString *)className pointer:(NSString *)pointer {
    
    NSMutableString * text = [NSMutableString new];
    [text appendFormat:@"❌❌ VC数量: %li, 最后位于\n%@   :%@\n%@", dic.allKeys.count, pointer, className, self.lineString];
    
    NSArray * originArray = dic.allValues;
    NSArray * result = [originArray sortedArrayUsingComparator:^NSComparisonResult(PoporWatchMemoryEntity * _Nonnull obj1, PoporWatchMemoryEntity * _Nonnull obj2) {
        return [obj1.className compare:obj2.className];
    }];
    
    for (PoporWatchMemoryEntity * entity in result) {
        if ([entity.pointer isEqualToString:pointer]) {
            [text appendFormat:@"\n%-16s : %@ ⚠️", entity.pointer.UTF8String, entity.className];
        } else if([entity.className isEqualToString:className]) {
            [text appendFormat:@"\n%-16s : %@ ⚠️", entity.pointer.UTF8String, entity.className];
        } else {
            [text appendFormat:@"\n%-16s : %@", entity.pointer.UTF8String, entity.className];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (WarmBlock) {
            WarmBlock(result, [[NSMutableAttributedString alloc] initWithString:text], className, pointer);
        } else {
            NSLog(@"\n%@\n\n%@\n\n%@", self.lineString, text, self.lineString);
        }
    });
}

+ (NSString *)lineString {
    return @"-------------------------------------";
}

+ (void)att:(NSMutableAttributedString *)att string:(NSString * _Nullable)string font:(UIFont * _Nullable)font color:(UIColor * _Nullable)color
{
    if (!string) {
        return;
    }
    NSRange range = NSMakeRange(0, string.length);
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    if (font) {
        [attString addAttribute:NSFontAttributeName value:font range:range];
    }
    if (color) {
        [attString addAttribute:NSForegroundColorAttributeName value:color range:range];
    }
    [att appendAttributedString:attString];
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
