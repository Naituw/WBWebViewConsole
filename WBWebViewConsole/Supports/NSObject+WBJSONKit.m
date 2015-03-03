//
//  NSObject+WBJSONKit.m
//  WBWebViewConsole
//
//  Created by 吴天 on 15/3/3.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "NSObject+WBJSONKit.h"

@implementation NSObject (WBJSONKit)

@end

@implementation NSString (WBJSONKit)

- (NSString *)wb_JSONString
{
    return [self copy];
}

- (id)wb_objectFromJSONString
{
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
}

@end

@implementation NSArray (WBJSONKit)

- (NSString *)wb_JSONString
{
    NSData * data = [NSJSONSerialization dataWithJSONObject:self options:0 error:NULL];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

@implementation NSDictionary (WBJSONKit)

- (NSString *)wb_JSONString
{
    NSData * data = [NSJSONSerialization dataWithJSONObject:self options:0 error:NULL];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
