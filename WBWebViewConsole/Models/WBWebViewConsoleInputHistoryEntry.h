//
//  WBWebViewConsoleInputHistoryEntry.h
//  Weibo
//
//  Created by Wutian on 14/7/27.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

@interface WBWebViewConsoleInputHistoryEntry : NSObject

@property (nonatomic, copy, readonly) NSString * text;
@property (nonatomic, assign, readonly) NSRange cursor;

+ (instancetype)emptyEntry;
+ (instancetype)entryWithText:(NSString *)text cursor:(NSRange)cursor;

@property (nonatomic, assign, readonly) BOOL isEmpty;

@end
