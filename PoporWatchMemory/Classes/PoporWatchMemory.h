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

typedef void(^PoporWatchMemoryBlock)(NSArray<PoporWatchMemoryEntity *> * array);

@interface PoporWatchMemory : NSObject

// [PoporWatchMemory watchVcIgnoreArray:@[@"UINavigationController"]];
+ (void)watchVcIgnoreArray:(NSArray * _Nullable)array;

+ (void)watchVcIgnoreArray:(NSArray * _Nullable)array warn:(PoporWatchMemoryBlock _Nullable)warmBlock;

@end

#pragma mark - 临时输出参数
@interface PoporWatchMemoryEntity : NSObject
@property (nonatomic, copy  ) NSString * className;
@property (nonatomic, copy  ) NSString * pointer;
@end

NS_ASSUME_NONNULL_END
