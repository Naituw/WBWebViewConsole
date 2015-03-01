//
//  WBJSBridgeAction.m
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

#import "WBJSBridgeAction.h"
#import "WBWebViewJSBridge.h"

@interface WBJSBridgeAction ()

@property (nonatomic, weak) WBWebViewJSBridge * bridge;
@property (nonatomic, strong) WBJSBridgeMessage * message;

@end

@implementation WBJSBridgeAction

- (instancetype)initWithBridge:(WBWebViewJSBridge *)bridge message:(WBJSBridgeMessage *)message
{
    if (self = [self init]) {
        self.bridge = bridge;
        self.message = message;
    }
    return self;
}

- (void)startAction
{
    [self actionFailed];
}

- (void)actionSuccessedWithResult:(NSDictionary *)result
{
    [self.bridge actionDidFinish:self success:YES result:result];
}

- (void)actionFailed
{
    [self.bridge actionDidFinish:self success:NO result:nil];
}

NSString * const WBJSBridgeActionNamePrefix = @"WBJSBridgeAction";

+ (Class)actionClassForActionName:(NSString *)actionName
{
    actionName = [actionName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[actionName substringToIndex:1].capitalizedString];
    
    NSString * actionClassName = [NSString stringWithFormat:@"%@%@", WBJSBridgeActionNamePrefix, actionName];
    Class klass = NSClassFromString(actionClassName);
    
    if (klass && [klass isSubclassOfClass:[WBJSBridgeAction class]]) {
        return klass;
    }
    
    return NULL;
}

@end
