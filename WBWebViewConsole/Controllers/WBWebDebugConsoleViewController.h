//
//  WBWebDebugConsoleViewController.h
//  Weibo
//
//  Created by Wutian on 14/7/23.
//  Copyright (c) 2014年 Sina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WBWebViewConsole;

@interface WBWebDebugConsoleViewController : UIViewController

- (instancetype)initWithConsole:(WBWebViewConsole *)console;

@property (nonatomic, strong) WBWebViewConsole * console;

@property (nonatomic, strong) NSString * initialCommand;

@end
