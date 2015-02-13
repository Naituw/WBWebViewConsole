//
//  WBWebViewJSBridge.h
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//  Copyright (c) 2015 Sina. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Minimal Version of Weibo's JSBridge
 */

@protocol WBWebView;
@class WBJSBridgeMessage, WBJSBridgeAction;

@interface WBWebViewJSBridge : NSObject

- (instancetype)initWithWebView:(id<WBWebView>)webView;

- (NSString *)javascriptSource;

- (BOOL)handleWebViewRequest:(NSURLRequest *)request;

- (void)actionDidFinish:(WBJSBridgeAction *)action success:(BOOL)success result:(NSDictionary *)result;

@end
