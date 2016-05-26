//
//  NSDictionary+WBTTypeCast.h
//  WBTool
//
//  Created by Wade Cheng on 8/19/13.
//
//  Copyright (c) 2013-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.

#import <Foundation/Foundation.h>

/*!
 *  本类主要功能是返还字典子节点的指定类型的值和遍历所有子节点让满足指定类型的子节点执行相应的block
 */
@interface NSDictionary (WBTTypeCast)
/*!
 *  返回当前key对应value的NSString值，没有则返回nil
 *
 *  @param key 用来获取当前字典对应值的key
 *  @return 当key对应的值为NSString类型时返回该值，没有则返回nil
 */
- (NSString *)wbt_stringForKey:(NSString *)key;

/*!
 *  返回当前key对应value的NSDictionary值，没有则返回nil
 *
 *  @param key 用来获取当前字典对应值的key
 *  @return 返回当前key对应value的NSDictionary值，不存在则返回Nil
 */
- (NSDictionary *)wbt_dictForKey:(NSString *)key;

/*!
 *  返回当前key对应value的NSArray值，没有则返回nil
 *
 *  @param key 用来获取当前字典对应值的key
 *  @return 返回当前key对应value的NSArray值，不存在则返回nil
 */
- (NSArray *)wbt_arrayForKey:(NSString *)key;

/*!
 *  返回当前key对应value的NSInteger值，没有则返回0
 *
 *  @param key 用来获取当前字典对应值的key
 *  @return 返回当前key对应value的NSInteger值，不存在则返回0
 */
- (NSInteger)wbt_integerForKey:(NSString *)key;

@end
