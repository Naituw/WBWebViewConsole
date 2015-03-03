//
//  NSObject+WBJSONKit.h
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

#import <Foundation/Foundation.h>

@interface NSObject (WBJSONKit)

@end

@interface NSString (WBJSONKit)

@property (nonatomic, copy, readonly) NSString * wb_JSONString;
@property (nonatomic, copy, readonly) id wb_objectFromJSONString;

@end

@interface NSArray (WBJSONKit)

@property (nonatomic, copy, readonly) NSString * wb_JSONString;

@end

@interface NSDictionary (WBJSONKit)

@property (nonatomic, copy, readonly) NSString * wb_JSONString;

@end

