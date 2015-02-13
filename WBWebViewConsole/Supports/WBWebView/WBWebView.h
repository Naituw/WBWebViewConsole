//
//  WBWebView.h
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//  Copyright (c) 2015 Sina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBWebViewUserScript.h"
#import "WBWebViewJSBridge.h"

/**
 *  Abstract version of Weibo's WBWebView
 *  The original one is an auto-switching wrapper of UIWebView & WKWebView
 */

@protocol WBWebView <NSObject>

@required
@property (nonatomic, strong, readonly) WBWebViewJSBridge * JSBridge;

- (void)wb_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(NSString *, NSError *))completionHandler;

- (void)wb_addUserScript:(WBWebViewUserScript *)userScript;
- (void)wb_removeAllUserScripts;

@property (nonatomic, readonly, copy) NSArray * wb_userScripts;

@end
