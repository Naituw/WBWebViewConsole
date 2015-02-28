//
//  WBWebViewConsoleMessage.m
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

#import "WBWebViewConsoleMessage.h"

@interface WBWebViewConsoleMessage ()

@property (nonatomic) WBWebViewConsoleMessageSource source;
@property (nonatomic) WBWebViewConsoleMessageType type;
@property (nonatomic) WBWebViewConsoleMessageLevel level;
@property (nonatomic, strong) NSString * message;

@property (nonatomic) NSInteger line;
@property (nonatomic) NSInteger column;
@property (nonatomic, strong) NSString * url;

@property (nonatomic, strong) NSString * caller;

@end

@implementation WBWebViewConsoleMessage


+ (instancetype)messageWithMessage:(NSString *)message type:(WBWebViewConsoleMessageType)type level:(WBWebViewConsoleMessageLevel)level source:(WBWebViewConsoleMessageSource)source
{
    return [self messageWithMessage:message type:type level:level source:source url:nil line:0 column:0];
}

+ (instancetype)messageWithMessage:(NSString *)message type:(WBWebViewConsoleMessageType)type level:(WBWebViewConsoleMessageLevel)level source:(WBWebViewConsoleMessageSource)source url:(NSString *)url line:(NSInteger)line column:(NSInteger)column
{
    WBWebViewConsoleMessage * result = [WBWebViewConsoleMessage new];
    
    result.message = message;
    result.type = type;
    result.level = level;
    result.source = source;
    result.url = url;
    result.line = line;
    result.column = column;
    result.caller = result.defaultCaller;
    
    return result;
}

+ (instancetype)messageWithMessage:(NSString *)message level:(WBWebViewConsoleMessageLevel)level source:(WBWebViewConsoleMessageSource)source caller:(NSString *)caller
{
    WBWebViewConsoleMessage * result = [WBWebViewConsoleMessage new];
    
    result.type = WBWebViewConsoleMessageTypeLog;
    result.source = source;
    result.level = level;
    result.message = message;
    result.caller = caller;
    
    return result;
}

@end

@implementation WBWebViewConsoleMessage (Caller)

- (NSString *)defaultCaller
{
    if (!_url.length) return nil;
    
    NSString * filename = nil;
    NSURL * url = [NSURL URLWithString:_url];
    if (url)
    {
        filename = [url.path lastPathComponent];
    }
    else
    {
        filename = [[_url componentsSeparatedByString:@"/"] lastObject];
    }
    
    if (!_line) return filename;
    
    return [NSString stringWithFormat:@"%@:%ld", filename, (long)_line];
}

@end
