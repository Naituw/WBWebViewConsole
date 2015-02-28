//
//  WBUIWebView.h
//  UIWebView+WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>
#import <WBWebView.h>

#define WBUIWebViewUsesPrivateAPI 1

@interface WBUIWebView : UIWebView <WBWebView>

@property (nonatomic, weak) id<UIWebViewDelegate> wb_delegate;

@end
