//
//  PoporWatchMemory.h
//  PoporWatchMemory
//
//  Created by popor on 2021/3/20.
//  Copyright © 2021 popor. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PoporWatchMemoryEntity;

typedef void(^PoporWatchMemoryBlock)(NSArray<PoporWatchMemoryEntity *> * array, NSMutableAttributedString * descAtt, NSString * className, NSString * pointer);

@interface PoporWatchMemory : NSObject

// [PoporWatchMemory watchVcIgnoreArray:@[@"UINavigationController"]];
+ (void)watchVcIgnoreArray:(NSArray * _Nullable)array;
+ (void)watchVcIgnoreArray:(NSArray * _Nullable)array att:(BOOL)useAtt warn:(PoporWatchMemoryBlock _Nullable)warmBlock;


+ (NSString *)lineString;

+ (void)att:(NSMutableAttributedString *)att string:(NSString * _Nullable)string font:(UIFont * _Nullable)font color:(UIColor * _Nullable)color;
+ (void)class:(Class)class oldSelector:(SEL _Nonnull)originalSelector newSelector:(SEL _Nonnull)swizzledSelector;

@end

#pragma mark - 临时输出参数
@interface PoporWatchMemoryEntity : NSObject
@property (nonatomic, copy  ) NSString * className;
@property (nonatomic, copy  ) NSString * pointer;
//@property (nonatomic        ) size_t instanceSize; // 初始化size
//@property (nonatomic        ) size_t mallocSize;   // 实际占用size

@end

NS_ASSUME_NONNULL_END
