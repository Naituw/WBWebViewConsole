//
//  UIDevice+WBTHelpers.h
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.

#if __IPHONE_7_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
#define IF_IOS7_OR_GREATER(...) if ([[UIDevice currentDevice] wbt_systemMainVersion] >= 7) { __VA_ARGS__ }
#else
#define IF_IOS7_OR_GREATER(...)
#endif

#define WBAvalibleOS(os_version)          ([[UIDevice currentDevice] wbt_systemMainVersion] >= os_version)

#import <UIKit/UIKit.h>

@interface UIDevice (WBTHelpers)

- (int)wbt_systemMainVersion;

@end
