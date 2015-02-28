//
//  UIDevice+WBTHelpers.m
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIDevice+WBTHelpers.h"

@implementation UIDevice (WBTHelpers)

static int systemMainVersion = 0;
- (int)wbt_systemMainVersion
{
    if (systemMainVersion > 0) {
        return systemMainVersion;
    }
    systemMainVersion = [self systemVersion].intValue;
    return systemMainVersion;
}

@end
