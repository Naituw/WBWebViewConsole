//
//  WBWebViewConsole.m
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

#import "WBWebViewConsole.h"
#import "WBWebViewConsoleMessage.h"
#import "WBWebViewConsoleUserPromptCompletionController.h"
#import "WBWebView.h"
#import "WBWebViewJSBridge.h"
#import "NSObject+WBJSONKit.h"

NSString * const WBWebViewConsoleDidAddMessageNotification = @"WBWebViewConsoleDidAddMessageNotification";
NSString * const WBWebViewConsoleDidClearMessagesNotification = @"WBWebViewConsoleDidClearMessagesNotification";

NSString * const WBWebViewConsoleLastSelectionElementName = @"WeiboConsoleLastSelection";

@interface WBWebViewConsole ()

@property (nonatomic, weak) id<WBWebView> webView;

@property (nonatomic, strong) NSMutableArray * consoleMessages;
@property (nonatomic, strong) NSMutableArray * consoleClearedMessages;

@property (nonatomic, strong) WBWebViewConsoleUserPromptCompletionController * completionController;

@end

@implementation WBWebViewConsole

- (id)init
{
    if (self = [super init])
    {
        self.consoleMessages = [NSMutableArray array];
        self.consoleClearedMessages = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithWebView:(id<WBWebView>)webView
{
    if (self = [self init]) {
        self.webView = webView;
    }
    return self;
}

- (void)setWebView:(id<WBWebView>)webView
{
    if (_webView != webView)
    {
        _webView = webView;
        
        if (webView)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addUserScriptToWebView:webView];
            });
        }
    }
}

- (void)addMessage:(NSString *)message type:(WBWebViewConsoleMessageType)type level:(WBWebViewConsoleMessageLevel)level source:(WBWebViewConsoleMessageSource)source
{
    [self addMessage:message type:type level:level source:source url:nil line:0 column:0];
}

- (void)addMessage:(NSString *)message type:(WBWebViewConsoleMessageType)type level:(WBWebViewConsoleMessageLevel)level source:(WBWebViewConsoleMessageSource)source url:(NSString *)url line:(NSInteger)line column:(NSInteger)column
{
    if (type == WBWebViewConsoleMessageTypeClear)
    {
        [self softClearMessages];
    }
    else
    {
        [self addMessage:[WBWebViewConsoleMessage messageWithMessage:message type:type level:level source:source url:url line:line column:column]];
    }
}

- (void)addMessage:(NSString *)message level:(WBWebViewConsoleMessageLevel)level source:(WBWebViewConsoleMessageSource)source caller:(NSString *)caller
{
    [self addMessage:[WBWebViewConsoleMessage messageWithMessage:message level:level source:source caller:caller]];
}

- (void)clearMessages
{
    [_consoleClearedMessages removeAllObjects];
    [_consoleMessages removeAllObjects];
    
    [self postConsoleNotification:WBWebViewConsoleDidClearMessagesNotification];
}

- (void)softClearMessages
{
    [_consoleClearedMessages addObjectsFromArray:_consoleMessages];
    [_consoleMessages removeAllObjects];
    
    [self postConsoleNotification:WBWebViewConsoleDidClearMessagesNotification];
}

- (void)reset
{
    [self clearMessages];
}

- (NSArray *)messages
{
    return _consoleMessages;
}
- (NSArray *)clearedMessages
{
    return _consoleClearedMessages;
}

- (void)addMessage:(WBWebViewConsoleMessage *)message
{
    [_consoleMessages addObject:message];
    
    [self postConsoleNotification:WBWebViewConsoleDidAddMessageNotification];
}

- (void)sendMessage:(NSString *)message
{
    [self addMessage:message type:WBWebViewConsoleMessageTypeLog level:WBWebViewConsoleMessageLevelLog source:WBWebViewConsoleMessageSourceUserCommand];

    NSString * encoded = [[message dataUsingEncoding:NSUTF8StringEncoding] base64Encoding]; // base64 encode
    
    NSString * js = [NSString stringWithFormat:@"__WeiboConsoleEvalResult = eval(decodeURIComponent(escape(window.atob('%@'))));", encoded];
    js = [js stringByAppendingString:@"window.__WeiboDebugConsole.stringifyObject(__WeiboConsoleEvalResult);"];
    
    [self.webView wb_evaluateJavaScript:js completionHandler:^(id result, NSError * error) {
        
        if (!result) return;
        
        NSString * string = result;
        if (![string isKindOfClass:[NSString class]])
        {
            string = [result wb_JSONString];
        }
        
        if ([string isKindOfClass:[NSString class]] && string.length)
        {
            [self addMessage:string type:WBWebViewConsoleMessageTypeLog level:WBWebViewConsoleMessageLevelDebug source:WBWebViewConsoleMessageSourceUserCommandResult];
        }
    }];
}

- (void)postConsoleNotification:(NSString *)notificationName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
}

#pragma mark - Prompt Completion

- (WBWebViewConsoleUserPromptCompletionController *)completionController
{
    if (!_completionController && _webView)
    {
        _completionController = [[WBWebViewConsoleUserPromptCompletionController alloc] initWithWebView:_webView];
    }
    return _completionController;
}

- (void)fetchSuggestionsForPrompt:(NSString *)prompt cursorIndex:(NSInteger)cursorIndex completion:(void (^)(NSArray * suggestions, NSRange replacementRange))completion
{
    [self.completionController fetchSuggestionsWithPrompt:prompt cursorIndex:cursorIndex completion:completion];
}

#pragma mark - Selection

- (void)storeCurrentSelectedElementToJavaScriptVariable:(NSString *)variable completion:(void (^)(BOOL success))completion
{
#define QUOTE(...) #__VA_ARGS__
    const char * js_char = \
    QUOTE(
    (function (name) {
        var selection = window.getSelection();
        if (!selection) return false;
        var node = selection.anchorNode;
        
        if (!node) {
            var iframes = document.querySelectorAll("iframe");
            for (var i = 0; i < iframes.length; i++) {
                var iframe = iframes[i];
                try {
                    var selection = iframe.contentWindow.getSelection();
                    if (!selection) continue;
                    var anchorNode = selection.anchorNode;
                    if (!anchorNode) continue;
                    node = anchorNode;
                    break;
                } catch (error) {
                    // we can't access this iframe
                }
            }
        }
        
        if (!node) return false;
        
        function storeElement(ele) {
            window[name] = ele;
        }
        
        var element = node;
        if (node.nodeType != 1) {
            // not a element node, see http://stackoverflow.com/questions/9979172/difference-between-node-object-and-element-object
            element = node.parentElement;
        }
        
        if (element) {
            storeElement(element);
            return true;
        }
        return false;
    })
    );
#undef QUOTE
    
    variable = variable ? : WBWebViewConsoleLastSelectionElementName;
    
    NSString * js = [NSString stringWithUTF8String:js_char];
    js = [js stringByAppendingFormat:@"('%@');", variable];
    
    [_webView wb_evaluateJavaScript:js completionHandler:^(id result, NSError * error) {
        BOOL success = NO;
        if ([result respondsToSelector:@selector(boolValue)])
        {
            success = [result boolValue];
        }
        if (completion) completion(success);
    }];
}

#pragma mark - JS

- (void)addUserScriptToWebView:(id<WBWebView>)webView
{
#define QUOTE(...) #__VA_ARGS__
    const char * js_char = \
    QUOTE(// replace console methods
          (function (config) {
        
        if (window.__WeiboDebugConsole) return;
        
        function __stringifyObject(result) {
            try {
                var resultType = typeof result;
                if (resultType == 'string') {
                    return '"' + result + '"';
                } else if (resultType == 'number' ||
                           resultType == 'boolean') {
                    return result;
                } else if (resultType == 'undefined') {
                    return 'undefined';
                } else if (result == null) {
                    return 'null';
                } else if (resultType == 'function') {
                    return result.toString();
                } else if (resultType == 'object') {
                    var cache = [];
                    var json = JSON.stringify(result, function(key, value) {
                        if (typeof value === 'object' && value !== null) {
                            if (cache.indexOf(value) !== -1) {
                                // circular reference found, discard key
                                return;
                            }
                            // store value in our collection
                            cache.push(value);
                            
                            if (value != result) {
                                // only print first level properties
                                // otherwise you will get huge return value, when you quering things like 'window'
                                return Object.prototype.toString.call(value);
                            }
                        }
                        return value;
                    }, 4); // indented 4 spaces
                    cache = null; // enable garbage collection
                    return json;
                }
            } catch (error) {
                return result;
            }
            return result;
        }
        
        window.__WeiboDebugConsole = {
        stringifyObject: function(object) {
            return __stringifyObject(object);
        }
        };
        
        if (!window.console) return;
        function isNumber(n) {
            return !isNaN(parseFloat(n)) && isFinite(n);
        }
        function __logWithParams(params) {
            var interfaceName = config && config['bridge'];
            if (interfaceName && window[interfaceName]) {
                window[interfaceName].invoke('privateConsoleLog', params);
            }
        }
        function __updateParams(params, error) {
            var stack = error.stack;
            do {
                if (!stack.length) break;
                
                var caller = stack.split("\n")[1];
                
                if (!caller) break;
                
                var info = caller;
                
                var at_index = caller.indexOf("@");
                
                if (at_index < 0 || at_index + 1 >= caller.length) {
                    info = caller;
                } else {
                    info = caller.substring(at_index + 1, caller.length);
                }
                
                do {
                    function getLastNumberAndTrimInfo() {
                        var colon_index = info.lastIndexOf(":");
                        
                        if (colon_index < 0 || colon_index + 1 >= info.length) {
                            return -1;
                        }
                        
                        var column = info.substring(colon_index + 1);
                        
                        if (!isNumber(column)) {
                            return -1;
                        }
                        
                        info = info.substring(0, colon_index);
                        
                        return column;
                    }
                    
                    // parse column no
                    var colno = getLastNumberAndTrimInfo();
                    if (colno == -1) break;
                    params.colno = colno;
                    
                    // parse line no
                    var lineno = getLastNumberAndTrimInfo();
                    if (lineno == -1) break;
                    params.lineno = lineno;
                    
                    // the rest is file
                    params.file = info;
                } while (0);
            } while (0);
            
            if (!params.lineno && params.colno) {
                params.lineno = params.colno;
                delete params.colno;
            }
            return params;
        }
        function __stringifyArgs(args) {
            var result = [];
            var n = args.length;
            for (var i = 0; i < n; i++) {
                arg = args[i];
                result.push(__stringifyObject(arg));
            }
            return result;
        }
        for (var key in console) {
            (function (name) {
                var func = console[name];
                if (typeof func != 'function') return;
                console[name] = function () {
                    var args = Array.prototype.slice.call(arguments, 0);
                    func.apply(console, args);
                    
                    var params = {
                        'func': name,
                        'args': __stringifyArgs(args),
                    };
                    
                    // retrive caller info
                    try {
                        throw Error("");
                    } catch (error) {
                        params = __updateParams(params, error);
                    }
                    __logWithParams(params);
                }
            }(key));
        }
        
        // catch errors
        (function () {
            
            window.addEventListener('error', function (event) {
                var params = {
                    'func': 'error',
                    'args': [event.message],
                    'file': event.filename,
                    'colno': event.colno,
                    'lineno': event.lineno,
                };
                __logWithParams(params);
            });
        }());
    }));
#undef QUOTE
    
    NSString * js = [NSString stringWithUTF8String:js_char];
    
    NSString * interface = self.webView.JSBridge.interfaceName;
    
    NSMutableDictionary * config = [NSMutableDictionary dictionary];
    
    if (interface) {
        config[@"bridge"] = interface;
    }
    
    js = [js stringByAppendingFormat:@"(%@)", config.wb_JSONString];
    
    WBWebViewUserScript * script = [WBWebViewUserScript scriptWithSource:js injectionTime:WBUserScriptInjectionTimeAtDocumentStart mainFrameOnly:NO];
    
    [webView wb_addUserScript:script];
}

@end
