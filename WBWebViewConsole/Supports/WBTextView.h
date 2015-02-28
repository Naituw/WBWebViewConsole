//
//  WBTextView.h
//  Weibo
//
//  Created by Stephen Liu on 14-3-12.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.

#import <UIKit/UIKit.h>

@class WBTextView;
@protocol WBTextViewDelegate <UITextViewDelegate>
@optional
- (void)textViewHeightChanged:(WBTextView *)textView;
- (void)textView:(WBTextView *)textView willChangeHeight:(NSInteger)height;
@end

@interface WBTextView : UITextView
@property (nonatomic, strong)UIColor *placeHolderColor;
@property (nonatomic, strong)NSString *placeHolder;
@property (nonatomic, assign)BOOL wraperWithScrollView;
@property (nonatomic, weak)id<WBTextViewDelegate> textDelegate;
@property (nonatomic, assign)NSInteger maxNumberOfLines;
@property (nonatomic, assign)NSInteger minNumberOfLines;
@property (nonatomic, assign)NSInteger minHeight;
@property (nonatomic, assign)NSInteger maxHeight;
@property (nonatomic, assign)BOOL animateHeightChange;
@end
