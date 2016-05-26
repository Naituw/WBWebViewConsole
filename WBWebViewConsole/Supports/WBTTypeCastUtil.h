//
//  TypeCastUtil.h
//  Weibo
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
 *  返回当前value的NSString的值，不是string则返回defaultValue
 *
 *  @param value 需要判断的对象
 *  @param defaultValue 一个默认的NSString类型值当需要判断的对象value不是NSString类型时则返回该默认值，没有则为Nil
 *
 *  @return 是NSString类型返回value，不是string则返回defaultValue
 */
NSString *wbt_stringOfValue(id value, NSString *defaultValue);

/*!
 *  返回当前value的NSDictionary值，不是则返回defaultValue
 *
 *  @param value 需要判断的对象
 *  @param defaultValue 一个默认的NSDictionary类型值当需要判断的对象value不是NSDictionary类型时则返回该默认值，没有则为Nil
 *
 *  @return 是NSDictionary类型返回value，不是则返回defaultValue
 */
NSDictionary *wbt_dictOfValue(id value, NSDictionary *defaultValue);

/*!
 *  返回当前value的NSArray值，不是则返回defaultValue
 *
 *  @param value 需要判断的对象
 *  @param defaultValue 一个默认的NSArray类型值当需要判断的对象value不是NSArray类型时则返回该默认值，没有则为Nil
 *
 *  @return 是NSArray类型返回value，不是则返回defaultValue
 */
NSArray *wbt_arrayOfValue(id value ,NSArray *defaultValue);

/*!
 *  返回当前value的NSInteger值，不是则返回defaultValue
 *
 *  @param value 一个默认的NSInteger类型值当需要判断的对象value不是NSInteger类型时则返回该默认值，没有则为Nil
 *  @param defaultValue 需要返回的默认值，没有则为Nil
 *
 *  @return 是NSInteger类型返回value，不是则返回defaultValue
 */
NSInteger wbt_integerOfValue(id value, NSInteger defaultValue);
