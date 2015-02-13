//
//  WBWebViewConsoleInputViewActionButton.h
//  Weibo
//
//  Created by Wutian on 14/7/28.
//  Copyright (c) 2014年 Sina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBWebViewConsoleInputViewActionButton : UIView

@property (nonatomic, weak) UIResponder * responder;

@property (nonatomic, assign) SEL previousHistorySelector;
@property (nonatomic, assign) SEL nextHistorySelector;
@property (nonatomic, assign) SEL dismissKeyboardSelector;
@property (nonatomic, assign) SEL newlineSelector;

@end