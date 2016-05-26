//
//  WBWebViewConsoleDefines.h
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
// 
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.

#ifndef WBWebViewConsole_WBWebViewConsoleDefines_h
#define WBWebViewConsole_WBWebViewConsoleDefines_h

#import "WBWebViewConsole.h"

inline static NSBundle * WBWebBrowserConsoleBundle()
{
    return [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@", [NSBundle bundleForClass:[WBWebViewConsole class]].bundlePath, @"WBWebBrowserConsole.bundle"]];
}

#endif
