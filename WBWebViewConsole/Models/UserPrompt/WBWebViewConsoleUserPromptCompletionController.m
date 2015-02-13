//
//  WBWebViewConsoleUserPromptCompletionController.m
//  Weibo
//
//  Created by Wutian on 14/7/25.
//  Copyright (c) 2014年 Sina. All rights reserved.
//

#import "WBWebViewConsoleUserPromptCompletionController.h"
#import "WBWebView.h"
#import "WBWebViewConsoleDefines.h"
#import <NSDictionary+Accessors/NSDictionary+Accessors.h>
#import <JSONKit.h>

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
    
//    NSInteger tokenIndex = 0;
//    NSString * sourceObject = @"window";
//    NSString * keyword = prompt;
//    NSInteger lastPeriodIndex = [prompt rangeOfString:@"." options:NSBackwardsSearch].location;
//    if (lastPeriodIndex != NSNotFound)
//    {
//        tokenIndex = lastPeriodIndex + 1;
//        sourceObject = [prompt substringToIndex:lastPeriodIndex];
//        keyword = [prompt substringFromIndex:lastPeriodIndex + 1];
//    }
//    
//    if (!sourceObject.length || !keyword.length)
//    {
//        failedBlock();
//        return;
//    }
//    
//    NSString * js = self.js;
//    js = [js stringByAppendingFormat:@"('%@', '%@');", [[sourceObject dataUsingEncoding:NSUTF8StringEncoding] base64Encoding], [[keyword dataUsingEncoding:NSUTF8StringEncoding] base64Encoding]];
    
    NSString * js = self.js;
    js = [js stringByAppendingFormat:@"('%@', %ld)", [[prompt dataUsingEncoding:NSUTF8StringEncoding] base64Encoding], (long)cursorIndex];
    
    [_webView wb_evaluateJavaScript:js completionHandler:^(id result, NSError * error) {
        if (![result isKindOfClass:[NSString class]])
        {
            failedBlock();
            return;
        }
        NSDictionary * resultDict = [result objectFromJSONString];
        NSArray * suggestions = [resultDict arrayForKey:@"completions"];
        NSInteger tokenStart = [resultDict integerForKey:@"token_start"];
        NSInteger tokenEnd = [resultDict integerForKey:@"token_end"];
        
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
