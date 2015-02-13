//
//  WBWebViewConsoleUserPromptCompletionController.h
//  Weibo
//
//  Created by Wutian on 14/7/25.
//  Copyright (c) 2014年 Sina. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WBWebView;

@interface WBWebViewConsoleUserPromptCompletionController : NSObject

- (instancetype)initWithWebView:(id<WBWebView>)webView;

- (void)fetchSuggestionsWithPrompt:(NSString *)prompt cursorIndex:(NSInteger)cursorIndex completion:(void (^)(NSArray * suggestions, NSRange replacementRange))completion;

@end
