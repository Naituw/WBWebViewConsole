//
//  WBWebViewConsoleUserPromptCompletionController.h
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

#import <Foundation/Foundation.h>

@protocol WBWebView;

@interface WBWebViewConsoleUserPromptCompletionController : NSObject

- (instancetype)initWithWebView:(id<WBWebView>)webView;

- (void)fetchSuggestionsWithPrompt:(NSString *)prompt cursorIndex:(NSInteger)cursorIndex completion:(void (^)(NSArray * suggestions, NSRange replacementRange))completion;

@end
