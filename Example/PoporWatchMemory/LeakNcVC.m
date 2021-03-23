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
    
    UIButton * button = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame =  CGRectMake(20, 20, 80, 40);
        [button setTitle:@"Post" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor brownColor]];
        
        button.layer.cornerRadius = 5;
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.layer.borderWidth = 1;
        button.clipsToBounds = YES;
        
        [self.view addSubview:button];
        
        [button addTarget:self action:@selector(btAction) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    });
    
    UILabel * oneL = ({
        UILabel * oneL = [UILabel new];
        oneL.frame               = CGRectMake(10, CGRectGetMaxY(button.frame) +20, self.view.frame.size.width -20, 0);
        oneL.backgroundColor     = [UIColor whiteColor]; // ios8 之前
        oneL.font                = [UIFont systemFontOfSize:15];
        oneL.textColor           = [UIColor blackColor];
        oneL.layer.masksToBounds = YES; // ios8 之后 lableLayer 问题
        oneL.numberOfLines       = 0;
        
        oneL.layer.cornerRadius  = 5;
        oneL.clipsToBounds       = YES;
        
        [self.view addSubview:oneL];
        oneL;
    });
    
    oneL.text = @"从 iOS 9 开始通知中心会对观察者进行弱引用，所以不需要在观察者对象释放之前从通知中心移除。但是，通过-[NSNotificationCenter addObserverForName:object:queue:usingBlock]方法注册的观察者依然需要手动的释放，因为通知中心对它们持有的是强引用。";
    
    [oneL sizeToFit];
}

- (void)ncAction {
    NSLog(@"%s", __func__);
}

- (void)btAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"333" object:nil];
}

/*
 //....................................................................................
 注释: https://www.it610.com/article/1280322444996919296.htm
 
 //....................................................................................
 NSNotificationCenter 是 iOS 开发中经常会用到的对象间通信方式，尤其是一对多和跨层通信。
 
 众所周知，在观察者对象释放之前，需要调用 removeObserver 方法，将观察者从通知中心移除，否则程序可能会出现崩溃。其实，从 iOS 9 开始，即使不移除观察者对象，程序也不会出现异常。这是为什么呢？我们先了解一下，为什么 iOS 9 之前需要手动移除观察者对象。
 
 观察者注册时，通知中心并不会对观察者对象做 retain 操作，而是对观察者对象进行unsafe_unretained 引用。
 
 什么是unsafe_unretained？因为 Cocoa 和 Cocoa Touch 中的一些类仍然还没有支持 weak 引用。所以，当我们想对这些类使用弱引用的时候，只能用unsafe_unretained来替代。
 
 // for attribute
 @property (unsafe_unretained) NSObject *unsafeProperty;
 // for variables
 NSObject *__unsafe_unretained unsafeReference;
 不安全引用（unsafe reference）和弱引用 (weak reference) 类似，它并不会让被引用的对象保持存活，但是和弱引用不同的是，当被引用的对象释放的时，不安全引用并不会自动被置为 nil，这就意味着它变成了野指针，而对野指针发送消息会导致程序崩溃。
 
 因此，观察者对象在释放之前必须从通知中心移除引用，否则通知中心就会给野指针所引用的对象发送消息，导致程序崩溃。既然如此，为什么通知中心不对观察者对象进行弱引用呢？我们刚才已经提到，Cocoa 和 Cocoa Touch 中的一些类还没有支持弱引用，所以采用不安全的引用只是为了兼容旧的版本。
 
 那么，为什么 iOS 9 之后观察者对象释放之前不需要从通知中心移除？我们可以看一下苹果文档的版本更新说明：
 
 In OS X 10.11 and iOS 9.0 NSNotificationCenter and NSDistributedNotificationCenter will no longer send notifications to registered observers that may be deallocated. If the observer is able to be stored as a zeroing-weak reference the underlying storage will store the observer as a zeroing weak reference, alternatively if the object cannot be stored weakly (i.e. it has a custom retain/release mechanism that would prevent the runtime from being able to store the object weakly) it will store the object as a non-weak zeroing reference. This means that observers are not required to un-register in their deallocation method. The next notification that would be routed to that observer will detect the zeroed reference and automatically un-register the observer. If an object can be weakly referenced notifications will no longer be sent to the observer during deallocation; the previous behavior of receiving notifications during dealloc is still present in the case of non-weakly zeroing reference observers. Block based observers via the -NSNotificationCenter addObserverForName:object:queue:usingBlock method still need to be un-registered when no longer in use since the system still holds a strong reference to these observers. Removing observers (either weakly referenced or zeroing referenced) prematurely is still supported. CFNotificationCenterAddObserver does not conform to this behavior since the observer may not be an object.
 
 //....................................................................................
 其中 zeroing-weak reference 就是指弱引用，从 iOS 9 开始通知中心会对观察者进行弱引用，所以不需要在观察者对象释放之前从通知中心移除。但是，通过-[NSNotificationCenter addObserverForName:object:queue:usingBlock]方法注册的观察者依然需要手动的释放，因为通知中心对它们持有的是强引用。
 
 
 //....................................................................................
 
 */

@end
