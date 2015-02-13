//
//  WBJSBridgeMessage.m
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//  Copyright (c) 2015 Sina. All rights reserved.
//

#import "WBJSBridgeMessage.h"
#import <NSDictionary+Accessors/NSDictionary+Accessors.h>

@interface WBJSBridgeMessage ()

@property (nonatomic, copy) NSString * action;
@property (nonatomic, copy) NSDictionary * parameters;

@property (nonatomic, copy) NSString * callbackID;

@end

@implementation WBJSBridgeMessage

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [self init]) {
        self.action = [dict stringForKey:@"action"];
        self.parameters = [dict dictionaryForKey:@"params"];
        self.callbackID = [dict stringForKey:@"callback_id"];
    }
    return self;
}

@end
