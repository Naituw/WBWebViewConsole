//
//  WBWebDebugConsoleViewController.h
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

#import <UIKit/UIKit.h>

@class WBWebViewConsole;

@interface WBWebDebugConsoleViewController : UIViewController

- (instancetype)initWithConsole:(WBWebViewConsole *)console;

@property (nonatomic, strong, readonly) WBWebViewConsole * console;

@property (nonatomic, strong) NSString * initialCommand;

@end
