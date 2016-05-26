//
//  WBJSBridgeActionPrivateConsoleLog.m
//  WBWebViewConsole
//
//  Created by 吴天 on 2/14/15.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "WBJSBridgeActionPrivateConsoleLog.h"
#import "WBWebViewConsole.h"
#import "WBWebViewJSBridge.h"
#import "WBWebView.h"
#import "NSDictionary+WBTTypeCast.h"

@implementation WBJSBridgeActionPrivateConsoleLog

- (void)startAction
{
    WBWebViewConsole * debugConsole = self.bridge.webView.console;
    
    NSDictionary * message = self.message.parameters;
    
    NSString * func = [message wbt_stringForKey:@"func"];
    
    if (!func) func = @"log";
    
    NSString * url = [message wbt_stringForKey:@"file"];
    NSInteger line = [message wbt_integerForKey:@"lineno"];
    NSInteger column = [message wbt_integerForKey:@"colno"];
    
    if ([func isEqual:@"clear"])
    {
        [debugConsole addMessage:nil type:WBWebViewConsoleMessageTypeClear level:WBWebViewConsoleMessageLevelInfo source:WBWebViewConsoleMessageSourceJS];
    }
    else if ([func isEqual:@"assert"])
    {
        NSArray * args = [message wbt_arrayForKey:@"args"];
        id condition = [args firstObject];
        
        if ([condition isKindOfClass:[NSNumber class]])
        {
            if ([condition boolValue])
            {
                return;
            }
        }
        
        if ([condition isKindOfClass:[NSString class]])
        {
            if ([condition length] &&
                ![condition isEqual:@"false"] &&
                ![condition isEqual:@"0"] &&
                ![condition isEqual:@"undefined"] &&
                ![condition isEqual:@"null"])
            {
                return;
            }
        }
        
        NSString * message = NSLocalizedString(@"Assert Failed: ", nil);
        
        if (args.count > 1)
        {
            NSString * reason = [[args subarrayWithRange:NSMakeRange(1, args.count - 1)] componentsJoinedByString:@" "];
            message = [message stringByAppendingString:reason];
        }
        
        [debugConsole addMessage:message type:WBWebViewConsoleMessageTypeAssert level:WBWebViewConsoleMessageLevelError source:WBWebViewConsoleMessageSourceJS url:url line:line column:column];
    }
    else
    {
        NSDictionary * levelMap = @{@"warn": @(WBWebViewConsoleMessageLevelWarning),
                                    @"error": @(WBWebViewConsoleMessageLevelError),
                                    @"debug": @(WBWebViewConsoleMessageLevelDebug),
                                    @"info": @(WBWebViewConsoleMessageLevelInfo),
                                    @"log": @(WBWebViewConsoleMessageLevelLog)};
        
        WBWebViewConsoleMessageLevel level = [levelMap[func] integerValue];
        
        NSArray * args = [message wbt_arrayForKey:@"args"];
        NSString * string = [args componentsJoinedByString:@" "];
        
        [debugConsole addMessage:string type:WBWebViewConsoleMessageTypeLog level:level source:WBWebViewConsoleMessageSourceJS url:url line:line column:column];
    }
    
    [self actionSuccessedWithResult:nil];
}

@end
