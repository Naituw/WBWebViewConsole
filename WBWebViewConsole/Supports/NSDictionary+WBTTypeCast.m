//
//  NSDictionary+WBTTypeCast.m
//  WBTool
//
//  Created by Wade Cheng on 8/19/13.
//
//  Copyright (c) 2013-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.

#import "NSDictionary+WBTTypeCast.h"
#import "WBTTypeCastUtil.h"

/**
 *  返回根据所给key值在当前字典对象上对应的值.
 */
#define OFK [self objectForKey:key]

@implementation NSDictionary (WBTTypeCast)

#pragma mark - NSString

- (NSString *)wbt_stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue;
{
    return wbt_stringOfValue(OFK, defaultValue);
}

- (NSString *)wbt_stringForKey:(NSString *)key;
{
    return [self wbt_stringForKey:key defaultValue:nil];
}

#pragma mark - NSDictionary

- (NSDictionary *)wbt_dictForKey:(NSString *)key defaultValue:(NSDictionary *)defaultValue
{
    return wbt_dictOfValue(OFK, defaultValue);
}

- (NSDictionary *)wbt_dictForKey:(NSString *)key
{
    return [self wbt_dictForKey:key defaultValue:nil];
}

- (NSDictionary *)wbt_dictionaryWithValuesForKeys:(NSArray *)keys
{
    return [self dictionaryWithValuesForKeys:keys];
}

#pragma mark - NSArray

- (NSArray *)wbt_arrayForKey:(NSString *)key defaultValue:(NSArray *)defaultValue
{
    return wbt_arrayOfValue(OFK, defaultValue);
}

- (NSArray *)wbt_arrayForKey:(NSString *)key
{
    return [self wbt_arrayForKey:key defaultValue:nil];
}

#pragma mark - NSInteger

- (NSInteger)wbt_integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;
{
    return wbt_integerOfValue(OFK, defaultValue);
}

- (NSInteger)wbt_integerForKey:(NSString *)key;
{
    return [self wbt_integerForKey:key defaultValue:0];
}

@end
