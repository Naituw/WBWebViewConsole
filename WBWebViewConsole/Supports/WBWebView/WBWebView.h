//
//  WBWebView.h
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.

#import <Foundation/Foundation.h>
#import "WBWebViewUserScript.h"
#import "WBWebViewJSBridge.h"

@class WBWebViewConsole;

/**
 *  Abstract version of Weibo's WBWebView
 *  The original one is an auto-switching wrapper of UIWebView & WKWebView
 */

@protocol WBWebView <NSObject>

@required
@property (nonatomic, strong, readonly) WBWebViewJSBridge * JSBridge;
@property (nonatomic, strong, readonly) WBWebViewConsole * console;

- (void)wb_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(NSString *, NSError *))completionHandler;

- (void)wb_addUserScript:(WBWebViewUserScript *)userScript;
- (void)wb_removeAllUserScripts;

@property (nonatomic, readonly, copy) NSArray * wb_userScripts;

@end
