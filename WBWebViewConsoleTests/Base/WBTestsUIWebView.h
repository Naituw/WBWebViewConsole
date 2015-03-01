//
//  WBTestsUIWebView.h
//  WBWebViewConsole
//
//  Created by 吴天 on 15/3/1.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>
#import "WBWebView.h"

@interface WBTestsUIWebView : UIWebView <WBWebView>

- (BOOL)syncLoadHTMLString:(NSString *)html error:(NSError **)error;

@end
