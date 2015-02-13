//
//  WBWebViewJSBridge.m
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//  Copyright (c) 2015 Sina. All rights reserved.
//

#import "WBWebViewJSBridge.h"
#import "WBWebView.h"
#import "WBWebViewUserScript.h"
#import "WBJSBridgeMessage.h"
#import "WBJSBridgeAction.h"
#import <JSONKit.h>

@interface WBWebViewJSBridge ()
{
    NSMutableArray *_actions;
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
        
        [webView wb_addUserScript:[WBWebViewUserScript scriptWithSource:self.javascriptSource injectionTime:WBUserScriptInjectionTimeAtDocumentStart mainFrameOnly:YES]];
    }
    return self;
}

- (NSString *)javascriptSource
{
    if (!_javascriptSource) {
        _javascriptSource = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"wbjs" ofType:@"js"] encoding:NSUTF8StringEncoding error:NULL];
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
    NSString * js = [NSString stringWithFormat:@"WeiboJSBridge._handleMessage(%@)", callback.JSONString];
    [self.webView wb_evaluateJavaScript:js completionHandler:NULL];
}

- (BOOL)handleWebViewRequest:(NSURLRequest *)request
{
    NSURL * url = request.URL;
    if ([url.scheme isEqual:@"wbjs"] &&
        [url.host isEqual:@"invoke"]) {
        
        [_webView wb_evaluateJavaScript:@"WeiboJSBridge._messageQueue()" completionHandler:^(NSString * result, NSError * error) {
            NSArray * queue = [result objectFromJSONString];
            if ([queue isKindOfClass:[NSArray class]]) {
                [self processMessageQueue:queue];
            }
        }];
        
        return YES;
    }
    return NO;
}

@end
