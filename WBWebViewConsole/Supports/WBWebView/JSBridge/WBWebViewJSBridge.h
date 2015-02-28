//
//  WBWebViewJSBridge.h
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

/**
 *  Minimal Version of Weibo's JSBridge
 */

@protocol WBWebView;
@class WBJSBridgeMessage, WBJSBridgeAction;

@interface WBWebViewJSBridge : NSObject

- (instancetype)initWithWebView:(id<WBWebView>)webView;

@property (nonatomic, weak, readonly) id<WBWebView> webView;

@property (nonatomic, copy) NSString * interfaceName;
@property (nonatomic, copy) NSString * readyEventName;
@property (nonatomic, copy) NSString * invokeScheme;

- (NSString *)javascriptSource;

- (BOOL)handleWebViewRequest:(NSURLRequest *)request;

- (void)actionDidFinish:(WBJSBridgeAction *)action success:(BOOL)success result:(NSDictionary *)result;

@end
