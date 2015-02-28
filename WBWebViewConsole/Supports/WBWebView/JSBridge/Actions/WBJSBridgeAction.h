//
//  WBJSBridgeAction.h
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
#import "WBJSBridgeMessage.h"

@class WBWebViewJSBridge;

@interface WBJSBridgeAction : NSObject

- (instancetype)initWithBridge:(WBWebViewJSBridge *)bridge message:(WBJSBridgeMessage *)message;

@property (nonatomic, weak, readonly) WBWebViewJSBridge * bridge;
@property (nonatomic, strong, readonly) WBJSBridgeMessage * message;

- (void)startAction;

- (void)actionSuccessedWithResult:(NSDictionary *)result;
- (void)actionFailed;

+ (Class)actionClassForActionName:(NSString *)actionName;

@end
