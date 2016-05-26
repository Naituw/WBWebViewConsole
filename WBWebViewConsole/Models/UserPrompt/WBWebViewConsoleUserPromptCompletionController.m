//
//  WBWebViewConsoleUserPromptCompletionController.m
//  Weibo
//
//  Created by Wutian on 14/7/25.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "WBWebViewConsoleUserPromptCompletionController.h"
#import "WBWebView.h"
#import "WBWebViewConsoleDefines.h"
#import "NSObject+WBJSONKit.h"
#import "NSDictionary+WBTTypeCast.h"

@interface WBWebViewConsoleUserPromptCompletionController ()

@property (nonatomic, weak) id<WBWebView> webView; // weak
@property (nonatomic, strong) NSString * js;

@end

@implementation WBWebViewConsoleUserPromptCompletionController


- (instancetype)initWithWebView:(id<WBWebView>)webView
{
    if (self = [super init])
    {
        self.webView = webView;
    }
    return self;
}

- (void)fetchSuggestionsWithPrompt:(NSString *)prompt cursorIndex:(NSInteger)cursorIndex completion:(void (^)(NSArray * suggestions, NSRange replacementRange))completion
{
    if (!completion) return;
    
    void (^failedBlock)(void) = ^{
        completion(nil, NSMakeRange(NSNotFound, 0));
    };
    
    if (!_webView)
    {
        failedBlock();
        return;
    }
    
    if (!prompt.length)
    {
        failedBlock();
        return;
    }
    
    NSString * js = self.js;
    js = [js stringByAppendingFormat:@"('%@', %ld)", [[prompt dataUsingEncoding:NSUTF8StringEncoding] base64Encoding], (long)cursorIndex];
    
    [_webView wb_evaluateJavaScript:js completionHandler:^(id result, NSError * error) {
        if (![result isKindOfClass:[NSString class]])
        {
            failedBlock();
            return;
        }
        NSDictionary * resultDict = [result wb_objectFromJSONString];
        NSArray * suggestions = [resultDict wbt_arrayForKey:@"completions"];
        NSInteger tokenStart = [resultDict wbt_integerForKey:@"token_start"];
        NSInteger tokenEnd = [resultDict wbt_integerForKey:@"token_end"];
        
        if (![suggestions isKindOfClass:[NSArray class]] || !suggestions.count)
        {
            failedBlock();
            return;
        }
        
        completion(suggestions, NSMakeRange(tokenStart, tokenEnd - tokenStart));
    }];
}

- (NSString *)js
{
    if (!_js)
    {
        NSString * jsPath = [WBWebBrowserConsoleBundle() pathForResource:@"console_prompt_completion" ofType:@"js"];
        NSString * js = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:NULL];
        _js = js;
    }
    return _js;
}

@end
