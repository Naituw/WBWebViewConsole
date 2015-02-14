//
//  WBUIWebView.h
//  UIWebView+WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//  Copyright (c) 2015 Sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WBWebView.h>

#define WBUIWebViewUsesPrivateAPI 1

@interface WBUIWebView : UIWebView <WBWebView>

@property (nonatomic, weak) id<UIWebViewDelegate> wb_delegate;

@end
