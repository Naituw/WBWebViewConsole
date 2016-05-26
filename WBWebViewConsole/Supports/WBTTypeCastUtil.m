//
//  WBTTypeCastUtil.m
//  Weibo
//
//  Created by Wade Cheng on 8/19/13.
//
//  Copyright (c) 2013-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.

#import "WBTTypeCastUtil.h"

NSString *wbt_stringOfValue(id value, NSString *defaultValue)
{
    if (![value isKindOfClass:[NSString class]])
    {
        if ([value isKindOfClass:[NSNumber class]])
        {
            return [value stringValue];
        }
        return defaultValue;
    }
    return value;
}

NSDictionary *wbt_dictOfValue(id value, NSDictionary *defaultValue)
{
    if ([value isKindOfClass:[NSDictionary class]])
        return value;
    
    return defaultValue;
}

NSArray *wbt_arrayOfValue(id value ,NSArray *defaultValue)
{
    if ([value isKindOfClass:[NSArray class]])
        return value;
    
    return defaultValue;
}

NSInteger wbt_integerOfValue(id value, NSInteger defaultValue)
{
    if ([value respondsToSelector:@selector(integerValue)])
        return [value integerValue];
    
    return defaultValue;
}
