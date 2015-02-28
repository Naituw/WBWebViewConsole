//
//  WBKeyboardObserver.h
//  Weibo
//
//  Created by Wutian on 14/6/27.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const WBKeyboardObserverFrameDidUpdateNotification;

@interface WBKeyboardObserver : NSObject

+ (instancetype)sharedObserver;

@property (nonatomic, assign) CGRect frameBegin;
@property (nonatomic, assign) CGRect frameEnd;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) UIViewAnimationCurve animationCurve;

@end
