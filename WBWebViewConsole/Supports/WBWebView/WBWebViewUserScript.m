//
//  WBWebViewUserScript.m
//  Weibo
//
//  Created by Wutian on 14/7/11.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "WBWebViewUserScript.h"

//#if __IPHONE_8_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
//#if kUsesWKWebView
//#import <WebKit/WKUserScript.h>
//
//@interface WKUserScript (WBAdditions) <WBWebViewUserScript>
//
//@end
//
//static inline WKUserScriptInjectionTime WKInjectionTimeFromWBInjectionTime(WBUserScriptInjectionTime time)
//{
//    switch (time)
//    {
//        case WBUserScriptInjectionTimeAtDocumentStart:
//            return WKUserScriptInjectionTimeAtDocumentStart;
//        case WBUserScriptInjectionTimeAtDocumentEnd:
//        default:
//            return WKUserScriptInjectionTimeAtDocumentEnd;
//    }
//}
//
//static inline WBUserScriptInjectionTime WBInjectionTimeFromWKInjectionTime(WKUserScriptInjectionTime time)
//{
//    switch (time)
//    {
//        case WKUserScriptInjectionTimeAtDocumentStart:
//            return WBUserScriptInjectionTimeAtDocumentStart;
//        case WKUserScriptInjectionTimeAtDocumentEnd:
//        default:
//            return WBUserScriptInjectionTimeAtDocumentEnd;
//    }
//}
//
//#endif
//#endif

@implementation WBWebViewUserScript


- (instancetype)initWithSource:(NSString *)source scriptInjectionTime:(WBUserScriptInjectionTime)injectionTime forMainFrameOnly:(BOOL)forMainFrameOnly
{
    if (self = [self init])
    {
        _source = [source copy];
        _scriptInjectionTime = injectionTime;
        _forMainFrameOnly = forMainFrameOnly;
    }
    return self;
}

+ (id)scriptWithSource:(NSString *)source injectionTime:(WBUserScriptInjectionTime)injectionTime mainFrameOnly:(BOOL)mainFrameOnly
{
//#if kUsesWKWebView
//    IF_IOS8_OR_GREATER({
//        return [[[WKUserScript alloc] initWithSource:source injectionTime:WKInjectionTimeFromWBInjectionTime(injectionTime) forMainFrameOnly:YES] autorelease];
//    })
//#endif

    return [[self alloc] initWithSource:source scriptInjectionTime:injectionTime forMainFrameOnly:mainFrameOnly];
}

@synthesize source = _source;
@synthesize scriptInjectionTime = _scriptInjectionTime;
@synthesize forMainFrameOnly = _forMainFrameOnly;
@end

//#if __IPHONE_8_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
//#if kUsesWKWebView
//
//@implementation WKUserScript (WBAdditions)
//
//- (WBUserScriptInjectionTime)scriptInjectionTime
//{
//    return WBInjectionTimeFromWKInjectionTime(self.injectionTime);
//}
//
//@end
//
//#endif
//#endif
