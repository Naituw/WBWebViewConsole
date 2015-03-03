//
//  WBWebViewJSBridge.m
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

#import "WBWebViewJSBridge.h"
#import "WBWebView.h"
#import "WBWebViewUserScript.h"
#import "WBJSBridgeMessage.h"
#import "WBJSBridgeAction.h"
#import "NSObject+WBJSONKit.h"

@interface WBWebViewJSBridge ()
{
    NSMutableArray *_actions;
    
    struct {
        unsigned int sourceNeedsUpdate: 1;
    } _flags;
}

@property (nonatomic, weak) id<WBWebView> webView;
@property (nonatomic, strong) NSString * javascriptSource;

@end

@implementation WBWebViewJSBridge

- (instancetype)initWithWebView:(id<WBWebView>)webView
{
    if (self = [super init]) {
        
        _actions = [[NSMutableArray alloc] init];
        
        self.webView = webView;
        self.interfaceName = @"WeiboJSBridge";
        self.readyEventName = @"WeiboJSBridgeReady";
        self.invokeScheme = @"wbjs://invoke";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [webView wb_addUserScript:[WBWebViewUserScript scriptWithSource:self.javascriptSource injectionTime:WBUserScriptInjectionTimeAtDocumentStart mainFrameOnly:YES]];
        });
    }
    return self;
}

- (void)setInterfaceName:(NSString *)interfaceName
{
    if (_interfaceName != interfaceName) {
        _interfaceName = interfaceName;
        _flags.sourceNeedsUpdate = YES;
    }
}

- (void)setReadyEventName:(NSString *)readyEventName
{
    if (_readyEventName != readyEventName) {
        _readyEventName = readyEventName;
        _flags.sourceNeedsUpdate = YES;
    }
}

- (void)setInvokeScheme:(NSString *)invokeScheme
{
    if (_invokeScheme != invokeScheme) {
        _invokeScheme = invokeScheme;
        _flags.sourceNeedsUpdate = YES;
    }
}

- (NSString *)javascriptSource
{
    if (!_javascriptSource || _flags.sourceNeedsUpdate) {
        
        NSBundle * bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle bundleForClass:[self class]] bundlePath], @"WBWebBrowserJSBridge.bundle"]];
        
        _javascriptSource = [[NSString alloc] initWithContentsOfFile:[bundle pathForResource:@"wbjs" ofType:@"js"] encoding:NSUTF8StringEncoding error:NULL];
        NSAssert(_interfaceName, @"interfaceName must not nil");
        NSAssert(_readyEventName, @"readyEventName must not nil");
        NSAssert(_invokeScheme, @"invokeScheme must not nil");
        
        NSDictionary * config = @{@"interface": _interfaceName,
                                  @"readyEvent": _readyEventName,
                                  @"invokeScheme": _invokeScheme};
        NSString * json = [config wb_JSONString];
        _javascriptSource = [_javascriptSource stringByAppendingFormat:@"(%@)", json];
    }
    return _javascriptSource;
}

- (void)processMessage:(WBJSBridgeMessage *)message
{
    WBJSBridgeAction * action = nil;
    
    Class klass = [WBJSBridgeAction actionClassForActionName:message.action];
    
    if (klass)
    {
        action = [[klass alloc] initWithBridge:self message:message];
    }

    if (action) {
        [_actions addObject:action];
        [action startAction];
    } else {
        [self sendCallbackForMessage:message success:NO result:nil];
    }
}

- (void)processMessageQueue:(NSArray *)queue
{
    for (NSDictionary * dict in queue) {
        WBJSBridgeMessage * message = [[WBJSBridgeMessage alloc] initWithDictionary:dict];
        [self processMessage:message];
    }
}

- (void)actionDidFinish:(WBJSBridgeAction *)action success:(BOOL)success result:(NSDictionary *)result
{
    if (![_actions containsObject:action]) return;
    
    [_actions removeObject:action];

    [self sendCallbackForMessage:action.message success:success result:result];
}

- (void)sendCallbackForMessage:(WBJSBridgeMessage *)message success:(BOOL)success result:(NSDictionary *)result
{
    if (!message.callbackID) {
        return;
    }
    NSDictionary * callback = @{@"params": result ? : @{},
                                @"failed": @(!success),
                                @"callback_id": message.callbackID};
    NSString * js = [NSString stringWithFormat:@"%@._handleMessage(%@)", _interfaceName, callback.wb_JSONString];
    [self.webView wb_evaluateJavaScript:js completionHandler:NULL];
}

- (BOOL)handleWebViewRequest:(NSURLRequest *)request
{
    NSURL * url = request.URL;
    if ([url.absoluteString isEqual:self.invokeScheme]) {
        NSString * js = [NSString stringWithFormat:@"%@._messageQueue()", _interfaceName];
        [_webView wb_evaluateJavaScript:js completionHandler:^(NSString * result, NSError * error) {
            NSArray * queue = [result wb_objectFromJSONString];
            if ([queue isKindOfClass:[NSArray class]]) {
                [self processMessageQueue:queue];
            }
        }];
        
        return YES;
    }
    return NO;
}

@end
