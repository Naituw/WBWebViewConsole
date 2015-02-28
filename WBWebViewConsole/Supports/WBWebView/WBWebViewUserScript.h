//
//  WBWebViewUserScript.h
//  Weibo
//
//  Created by Wutian on 14/7/11.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WBUserScriptInjectionTime) {
    WBUserScriptInjectionTimeAtDocumentStart,
    WBUserScriptInjectionTimeAtDocumentEnd
};

@protocol WBWebViewUserScript <NSObject>

@property (nonatomic, copy, readonly) NSString * source;
@property (nonatomic, readonly) WBUserScriptInjectionTime scriptInjectionTime;
@property (nonatomic, readonly, getter=isForMainFrameOnly) BOOL forMainFrameOnly;

@end

@interface WBWebViewUserScript : NSObject <WBWebViewUserScript>

+ (id)scriptWithSource:(NSString *)source injectionTime:(WBUserScriptInjectionTime)injectionTime mainFrameOnly:(BOOL)mainFrameOnly;

@end
