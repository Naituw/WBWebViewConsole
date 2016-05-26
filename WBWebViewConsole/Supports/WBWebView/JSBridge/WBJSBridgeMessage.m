//
//  WBJSBridgeMessage.m
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "WBJSBridgeMessage.h"
#import "NSDictionary+WBTTypeCast.h"

@interface WBJSBridgeMessage ()

@property (nonatomic, copy) NSString * action;
@property (nonatomic, copy) NSDictionary * parameters;

@property (nonatomic, copy) NSString * callbackID;

@end

@implementation WBJSBridgeMessage

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [self init]) {
        self.action = [dict wbt_stringForKey:@"action"];
        self.parameters = [dict wbt_dictForKey:@"params"];
        self.callbackID = [dict wbt_stringForKey:@"callback_id"];
    }
    return self;
}

@end
