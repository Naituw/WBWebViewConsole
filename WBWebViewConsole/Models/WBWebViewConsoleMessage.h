//
//  WBWebViewConsoleMessage.h
//  Weibo
//
//  Created by Wutian on 14/7/23.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WBWebViewConsoleMessageSource)
{
    WBWebViewConsoleMessageSourceJS = 0,
    WBWebViewConsoleMessageSourceNavigation,
    WBWebViewConsoleMessageSourceUserCommand,
    WBWebViewConsoleMessageSourceUserCommandResult,
    WBWebViewConsoleMessageSourceNative,
};

typedef NS_ENUM(NSInteger, WBWebViewConsoleMessageType)
{
    WBWebViewConsoleMessageTypeLog = 0,
    WBWebViewConsoleMessageTypeClear,
    WBWebViewConsoleMessageTypeAssert,
};

typedef NS_ENUM(NSInteger, WBWebViewConsoleMessageLevel)
{
    WBWebViewConsoleMessageLevelNone = 0,
    WBWebViewConsoleMessageLevelLog = 1,
    WBWebViewConsoleMessageLevelWarning = 2,
    WBWebViewConsoleMessageLevelError = 3,
    WBWebViewConsoleMessageLevelDebug = 4,
    WBWebViewConsoleMessageLevelInfo = 5,
    WBWebViewConsoleMessageLevelSuccess = 6,
};

@interface WBWebViewConsoleMessage : NSObject

@property (nonatomic, readonly) WBWebViewConsoleMessageSource source;
@property (nonatomic, readonly) WBWebViewConsoleMessageType type;
@property (nonatomic, readonly) WBWebViewConsoleMessageLevel level;
@property (nonatomic, strong, readonly) NSString * message;

@property (nonatomic, readonly) NSInteger line;
@property (nonatomic, readonly) NSInteger column;
@property (nonatomic, strong, readonly) NSString * url;

@property (nonatomic, strong, readonly) NSString * caller;

@property (nonatomic, readonly) NSInteger repeatCount;

+ (instancetype)messageWithMessage:(NSString *)message type:(WBWebViewConsoleMessageType)type level:(WBWebViewConsoleMessageLevel)level source:(WBWebViewConsoleMessageSource)source;
+ (instancetype)messageWithMessage:(NSString *)message type:(WBWebViewConsoleMessageType)type level:(WBWebViewConsoleMessageLevel)level source:(WBWebViewConsoleMessageSource)source url:(NSString *)url line:(NSInteger)line column:(NSInteger)column;
+ (instancetype)messageWithMessage:(NSString *)message level:(WBWebViewConsoleMessageLevel)level source:(WBWebViewConsoleMessageSource)source caller:(NSString *)caller;

@end

@interface WBWebViewConsoleMessage (Caller)

@property (nonatomic, strong, readonly) NSString * defaultCaller;

@end
