//
//  WBTestsUIWebView.m
//  WBWebViewConsole
//
//  Created by 吴天 on 15/3/1.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "WBTestsUIWebView.h"
#import "WBWebViewConsole.h"

@class WBTestsUIWebView;

@interface NSError (WBTestsUIWebView)

- (BOOL)wb_isWebViewMainFrameError:(WBTestsUIWebView *)webView;
- (BOOL)wb_shouldDisplayToWebViewUsers:(WBTestsUIWebView *)webView;

@end

@interface WBTestsUIWebView () <UIWebViewDelegate>

@property (nonatomic, strong) NSMutableArray * userScripts;
@property (nonatomic, strong) WBWebViewJSBridge * JSBridge;
@property (nonatomic, strong) WBWebViewConsole * console;

@property (nonatomic, strong) NSURLRequest * loadingRequest;
@property (nonatomic, strong) NSError * loadingError;
@property (nonatomic, assign) NSInteger loadingCount;

@property (nonatomic, assign) BOOL pendingRequest;

@end

@implementation WBTestsUIWebView

- (instancetype)init
{
    if (self = [self initWithFrame:CGRectMake(0, 0, 10, 10)]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.JSBridge = [[WBWebViewJSBridge alloc] initWithWebView:self];
        self.console = [[WBWebViewConsole alloc] initWithWebView:self];
    }
    return self;
}

- (NSMutableArray *)userScripts
{
    if (!_userScripts) {
        _userScripts = [NSMutableArray array];
    }
    return _userScripts;
}

- (void)wb_addUserScript:(WBWebViewUserScript *)userScript
{
    if (!userScript) {
        return;
    }
    [self.userScripts addObject:userScript];
}

- (void)wb_removeAllUserScripts
{
    [_userScripts removeAllObjects];
}

- (NSArray *)wb_userScripts
{
    return [_userScripts copy];
}

- (void)injectUserScripts
{
    for (WBWebViewUserScript * script in _userScripts) {
        [self stringByEvaluatingJavaScriptFromString:script.source];
    }
}

- (void)wb_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(NSString *, NSError *))completionHandler
{
    NSString * result = [self stringByEvaluatingJavaScriptFromString:javaScriptString];
    
    if (completionHandler) {
        completionHandler(result, nil);
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL result = YES;
    
    if ([self.JSBridge handleWebViewRequest:request]) {
        result = NO;
    }
    
    if (result) {
        self.loadingRequest = request;
    }
    
    return result;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.loadingCount++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self injectUserScripts];
    
    self.loadingCount--;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error wb_shouldDisplayToWebViewUsers:self]) {
        self.loadingError = error;
    }
    self.loadingCount--;
}

- (void)setLoadingCount:(NSInteger)loadingCount
{
    if (_loadingCount != loadingCount) {
        _loadingCount = MAX(loadingCount, 0);
        
        if (loadingCount == 0) {
            _pendingRequest = NO;
        }
    }
}

- (BOOL)syncLoadHTMLString:(NSString *)html error:(NSError *__autoreleasing *)error
{
    self.pendingRequest = YES;
    [self loadHTMLString:html baseURL:nil];
    
    while (_pendingRequest) {
        [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    if (error && _loadingError) {
        *error = _loadingError;
    }
    
    return _loadingError == nil;
}

@end

@implementation NSError (WBTestsUIWebView)

- (BOOL)wb_isWebViewMainFrameError:(WBTestsUIWebView *)webView
{
    NSString * url = [[self userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey];
    NSString * host = [[NSURL URLWithString:url] host];
    
    if (![host isEqual:webView.request.URL.host] &&
        ![host isEqual:webView.loadingRequest.URL.host])
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)wb_shouldDisplayToWebViewUsers:(WBTestsUIWebView *)webView
{
    if (![self wb_isWebViewMainFrameError:webView]) {
        return NO;
    }
    
    if ([self.domain isEqual:NSURLErrorDomain])
    {
        if (self.code == NSURLErrorCancelled)
        {
            // interrupted by http redirect, etc.
            return NO;
        }
        
        return YES;
    }
    else if ([self.domain isEqual:@"WebKitErrorDomain"])
    {
        if (self.code == 102)
        {
            // interrupted by urlAction, JSBridge, etc.
            return NO;
        }
        else if (self.code == 204)
        {
            // interrupted by plugIn, such as movie(music) player
            return NO;
        }
        
        return YES;
    }
    
    return NO;
}

@end
