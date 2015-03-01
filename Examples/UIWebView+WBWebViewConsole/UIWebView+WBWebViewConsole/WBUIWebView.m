//
//  WBUIWebView.m
//  UIWebView+WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "WBUIWebView.h"
#import <WBWebViewConsole/WBWebViewConsole.h>

@interface WBUIWebView () <UIWebViewDelegate>
{
    struct {
        unsigned int shouldStartLoad:1;
        unsigned int didStartLoad:1;
        unsigned int didFinishLoad:1;
        unsigned int didFailLoad:1;
    } _delegateHas;
}

@property (nonatomic, strong) NSMutableArray * userScripts;
@property (nonatomic, strong) WBWebViewJSBridge * JSBridge;
@property (nonatomic, strong) WBWebViewConsole * console;

@end

@implementation WBUIWebView

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

- (void)setWb_delegate:(id<UIWebViewDelegate>)wb_delegate
{
    if (_wb_delegate != wb_delegate) {
        _wb_delegate = wb_delegate;
        
        _delegateHas.shouldStartLoad = [wb_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)];
        _delegateHas.didStartLoad = [wb_delegate respondsToSelector:@selector(webViewDidStartLoad:)];
        _delegateHas.didFinishLoad = [wb_delegate respondsToSelector:@selector(webViewDidFinishLoad:)];
        _delegateHas.didFailLoad = [wb_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL result = YES;
    
    if ([self.JSBridge handleWebViewRequest:request]) {
        result = NO;
    } else if (_delegateHas.shouldStartLoad) {
        result = [_wb_delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    if (result) {
        [self webDebugLogProvisionalNavigation:request navigationType:navigationType result:result];
    }
    
    return result;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (_delegateHas.didStartLoad) {
        [_wb_delegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
#if !WBUIWebViewUsesPrivateAPI
    [self injectUserScripts];
#endif
    
    if (_delegateHas.didFinishLoad) {
        [_wb_delegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (_delegateHas.didFailLoad) {
        [_wb_delegate webView:webView didFailLoadWithError:error];
    }
    
    [self webDebugLogLoadFailedWithError:error];
}

#if WBUIWebViewUsesPrivateAPI

#warning Private API here, DO NOT use in production code

- (void)webView:(id)webView didClearWindowObject:(id)window forFrame:(id)frame
{
    [self injectUserScripts];
}

#endif

- (NSString *)callerWithNavigationType:(UIWebViewNavigationType)type
{
    switch (type)
    {
        case UIWebViewNavigationTypeBackForward: return @"back/forward";
        case UIWebViewNavigationTypeFormResubmitted: return @"form resubmit";
        case UIWebViewNavigationTypeFormSubmitted: return @"form submit";
        case UIWebViewNavigationTypeLinkClicked: return @"link click";
        case UIWebViewNavigationTypeReload: return @"reload";
        default: return nil;
    }
}

- (void)webDebugLogInfo:(NSString *)info
{
    [self.console addMessage:info type:WBWebViewConsoleMessageTypeLog level:WBWebViewConsoleMessageLevelInfo source:WBWebViewConsoleMessageSourceNative];
}

- (void)webDebugLogProvisionalNavigation:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType result:(BOOL)result
{
    if (![[[request URL] absoluteString] isEqualToString:[[request mainDocumentURL] absoluteString]]) return;
    
    NSString * message = request.URL.absoluteString;
    WBWebViewConsoleMessageLevel level = result ? WBWebViewConsoleMessageLevelSuccess : WBWebViewConsoleMessageLevelWarning;
    NSString * caller = [self callerWithNavigationType:navigationType];
    
    if (caller)
    {
        caller = [NSString stringWithFormat:@"triggered by %@", caller];
    }
    
    [self.console addMessage:message level:level source:WBWebViewConsoleMessageSourceNavigation caller:caller];
}

- (void)webDebugLogLoadFailedWithError:(NSError *)error
{
    if ([error.domain isEqual:NSURLErrorDomain] && error.code == NSURLErrorCancelled)
    {
        return;
    }
    
    NSString * url = error.userInfo[NSURLErrorFailingURLStringErrorKey];
    NSString * message = nil, * caller = nil;
    
    if (url)
    {
        NSMutableString * m = [NSMutableString string];
        
        [m appendFormat:@"domain: %@, ", error.domain];
        [m appendFormat:@"code: %ld, ", (long)error.code];
        [m appendFormat:@"reason: %@", error.localizedDescription];
        
        message = m;
        caller = url;
    }
    else
    {
        message = error.description;
    }
    
    [self.console addMessage:message level:WBWebViewConsoleMessageLevelError source:WBWebViewConsoleMessageSourceNative caller:caller];
}

@end
