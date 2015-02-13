//
//  UIDevice+WBTHelpers.m
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//  Copyright (c) 2015 Sina. All rights reserved.
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
