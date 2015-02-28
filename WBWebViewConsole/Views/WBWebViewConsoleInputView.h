//
//  WBWebViewConsoleInputView.h
//  Weibo
//
//  Created by Wutian on 14/7/24.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>
#import "WBTextView.h"

@class WBWebViewConsole;
@protocol WBWebViewConsoleInputViewDelegate;

@interface WBWebViewConsoleInputView : UIView

@property (nonatomic, weak) id<WBWebViewConsoleInputViewDelegate> delegate;

@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong, readonly) WBTextView * textView;
@property (nonatomic, strong) WBWebViewConsole * console;

- (void)setFont:(UIFont *)font;

@property (nonatomic, assign, readonly) CGFloat desiredHeight;

- (void)completePromptWithSuggestion:(NSString *)suggestion;

@end

@protocol WBWebViewConsoleInputViewDelegate <NSObject>

- (void)consoleInputViewHeightChanged:(WBWebViewConsoleInputView *)inputView;
- (void)consoleInputViewDidBeginEditing:(WBWebViewConsoleInputView *)inputView;
- (void)consoleInputView:(WBWebViewConsoleInputView *)inputView didCommitCommand:(NSString *)command;

@end
