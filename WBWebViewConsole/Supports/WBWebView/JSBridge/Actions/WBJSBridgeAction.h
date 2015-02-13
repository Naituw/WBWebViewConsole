//
//  WBJSBridgeAction.h
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//  Copyright (c) 2015 Sina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WBWebViewJSBridge, WBJSBridgeMessage;

@interface WBJSBridgeAction : NSObject

- (instancetype)initWithBridge:(WBWebViewJSBridge *)bridge message:(WBJSBridgeMessage *)message;

@property (nonatomic, weak, readonly) WBWebViewJSBridge * bridge;
@property (nonatomic, strong, readonly) WBJSBridgeMessage * message;

- (void)startAction;

- (void)actionSuccessedWithResult:(NSDictionary *)result;
- (void)actionFailed;

+ (Class)actionClassForActionName:(NSString *)actionName;

@end
