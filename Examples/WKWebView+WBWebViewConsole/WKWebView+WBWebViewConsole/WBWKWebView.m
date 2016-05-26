//
//  WBWKWebView.m
//  WKWebView+WBWebViewConsole
//
//  Created by 吴天 on 15/2/25.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "WBWKWebView.h"
#import <WBWebViewConsole/WBWebViewJSBridge.h>
#import <WBWebViewConsole/WBWebViewConsole.h>
#import <WBWebViewConsole/NSObject+WBJSONKit.h>
#import <WBWebViewConsole/WBWebViewUserScript.h>

@interface WBWKWebView () <WKNavigationDelegate>

@property (nonatomic, strong) WBWebViewJSBridge * JSBridge;
@property (nonatomic, strong) WBWebViewConsole * console;

@end

@implementation WBWKWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.navigationDelegate = self;
        self.JSBridge = [[WBWebViewJSBridge alloc] initWithWebView:self];
        
        self.console = [[WBWebViewConsole alloc] initWithWebView:self];
    }
    return self;
}

- (void)wb_addUserScript:(WBWebViewUserScript *)userScript
{
    if (!userScript) {
        return;
    }
    [self.configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:userScript.source injectionTime:(WKUserScriptInjectionTime)userScript.scriptInjectionTime forMainFrameOnly:userScript.forMainFrameOnly]];
}

- (void)wb_removeAllUserScripts
{
    [self.configuration.userContentController removeAllUserScripts];
}

- (NSArray *)wb_userScripts
{
    return self.configuration.userContentController.userScripts;
}

- (void)wb_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(NSString *, NSError *))completionHandler
{
    [self evaluateJavaScript:javaScriptString completionHandler:^(id result, NSError * error) {
        if (completionHandler) {
            NSString * resultString = nil;
            
            if ([result isKindOfClass:[NSString class]]) {
                resultString = result;
            } else if ([result respondsToSelector:@selector(stringValue)]) {
                resultString = [result stringValue];
            } else if ([result respondsToSelector:@selector(wb_JSONString)]) {
                resultString = [result wb_JSONString];
            }
            
            completionHandler(resultString, error);
        }
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL result = YES;
    
    if ([self.JSBridge handleWebViewRequest:navigationAction.request]) {
        result = NO;
    }
    
    if (result) {
        [self webDebugLogProvisionalNavigation:navigationAction.request navigationType:navigationAction.navigationType result:result];
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self webDebugLogLoadFailedWithError:error];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self webDebugLogLoadFailedWithError:error];
}

- (NSString *)callerWithNavigationType:(WKNavigationType)type
{
    switch (type)
    {
        case WKNavigationTypeBackForward: return @"back/forward";
        case WKNavigationTypeFormResubmitted: return @"form resubmit";
        case WKNavigationTypeFormSubmitted: return @"form submit";
        case WKNavigationTypeLinkActivated: return @"link click";
        case WKNavigationTypeReload: return @"reload";
        default: return nil;
    }
}

- (void)webDebugLogInfo:(NSString *)info
{
    [self.console addMessage:info type:WBWebViewConsoleMessageTypeLog level:WBWebViewConsoleMessageLevelInfo source:WBWebViewConsoleMessageSourceNative];
}

- (void)webDebugLogProvisionalNavigation:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType result:(BOOL)result
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
