//
//  WBWebViewConsoleInputViewActionButton.h
//  Weibo
//
//  Created by Wutian on 14/7/28.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

@interface WBWebViewConsoleInputViewActionButton : UIView

@property (nonatomic, weak) UIResponder * responder;

@property (nonatomic, assign) SEL previousHistorySelector;
@property (nonatomic, assign) SEL nextHistorySelector;
@property (nonatomic, assign) SEL dismissKeyboardSelector;
@property (nonatomic, assign) SEL newlineSelector;

@end