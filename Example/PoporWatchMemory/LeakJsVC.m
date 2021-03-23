//
//  LeakJsVC.m
//  PoporWatchMemory_Example
//
//  Created by popor on 2021/3/23.
//  Copyright © 2021 popor. All rights reserved.
//

#import "LeakJsVC.h"
#import <WebKit/WebKit.h>

static NSString * JsKey_demo = @"JsKey_demo";

#define JsFunNameArray @[JsKey_demo]

@interface LeakJsVC () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic, copy  ) NSString  * rootUrl;
@property (nonatomic, strong) WKWebView * infoWV;
@property (nonatomic, strong) WKWebViewConfiguration  * configuration;
@property (nonatomic, strong) WKUserContentController * userController;

@end

@implementation LeakJsVC

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSLog(@"\n\n❌❌不执行remove js的话, 会导致泄漏.❌❌\n");
    for (NSString * name in JsFunNameArray) {
        // [self.userController removeScriptMessageHandlerForName:name];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"";
    
    self.rootUrl = @"https://www.baidu.com";
    [self addWebView];
    
    {
        UILabel * oneL = ({
            UILabel * oneL = [UILabel new];
            oneL.frame               = CGRectMake(10, +20, self.view.frame.size.width -20, 0);
            oneL.backgroundColor     = [UIColor lightGrayColor]; // ios8 之前
            oneL.font                = [UIFont systemFontOfSize:15];
            oneL.textColor           = [UIColor blackColor];
            oneL.layer.masksToBounds = YES; // ios8 之后 lableLayer 问题
            oneL.numberOfLines       = 0;
            
            oneL.layer.cornerRadius  = 5;
            oneL.clipsToBounds       = YES;
            
            [self.view addSubview:oneL];
            oneL;
        });
        
        oneL.text = @"[self.userController removeScriptMessageHandlerForName:name];\n不执行remove js的话, 会导致泄漏.";
        
        [oneL sizeToFit];
    }
}

- (void)addWebView {
    WKWebViewConfiguration  * configuration   = [[WKWebViewConfiguration alloc] init];
    WKUserContentController * userController  = [[WKUserContentController alloc] init];
    configuration.userContentController = userController;
    configuration.allowsInlineMediaPlayback = YES; // https://www.jianshu.com/p/e1e3eb7d4f7e 允许h5在页面内部播放的配置.
    
    [self registerJs_configuration:configuration userController:userController]; // 注册js
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsInlineMediaPlayback = YES;
    config.requiresUserActionForMediaPlayback = NO;
    
    {   // 注释 音视频js代码
        // https://blog.csdn.net/levebe/article/details/105996359
        //js代码, 这里包房视频播放停止的函数: playPause()
        NSString *videos = @"var myvideo = document.getElementById('myvideo');function playPause(){myvideo.pause()}";
        // 注入网页停止播放音乐的js代码
        WKUserScript *pauseJS = [[WKUserScript alloc]initWithSource:videos injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        [userController addUserScript:pauseJS];
    }
    
    
    if (!self.infoWV) {
        WKWebView * web = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        
        if (@available(iOS 11, *)) {
            //web.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
            web.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
        {
            //NSLogString(self.rootUrl);
            NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.rootUrl]];
            
            [web loadRequest:request];
        }
        
        web.UIDelegate         = self;
        web.navigationDelegate = self;
        web.allowsBackForwardNavigationGestures = YES;
        
        [self.view addSubview:web];
        
        self.infoWV = web;
    }
}

- (void)registerJs_configuration:(WKWebViewConfiguration *)configuration userController:(WKUserContentController *)userController {
    self.configuration  = configuration;
    self.userController = userController;
    // 监听需要的js函数名称
    for (NSString * name in JsFunNameArray) {
        [self.userController addScriptMessageHandler:self name:name];
    }
    
    //    @weakify(self);
    //    [[[self rac_signalForSelector:@selector(viewDidDisappear:)] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(RACTuple * _Nullable x) {
    //        @strongify(self);
    //
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            if (self.isWillDeallocWhenDisappear) {
    //                for (NSString * name in JsFunNameArray) {
    //                    [self.userController removeScriptMessageHandlerForName:name];
    //                }
    //            }
    //        });
    //    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    // ... do someting
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if([error code] == NSURLErrorCancelled)  {
        return;
    }
    NSLog(@"PoporWKWebVC error : %@", error.localizedDescription);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 加载好之后禁止 选择和查看图片
    [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';"   completionHandler:nil];
    
    self.title = webView.title;
}

// js h5 交互: https://github.com/wang82426107/WKWebViewDemo/tree/master
//JS调用的OC回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:JsKey_demo]) {
        // do someting
        
        return;
    }
}

@end
