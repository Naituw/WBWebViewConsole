//
//  WBJSBridgeMessage.h
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

@interface WBJSBridgeMessage : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, copy, readonly) NSString * action;
@property (nonatomic, copy, readonly) NSDictionary * parameters;

@property (nonatomic, copy, readonly) NSString * callbackID;

@end
