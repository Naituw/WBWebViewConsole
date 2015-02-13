//
//  WBKeyboardObserver.h
//  Weibo
//
//  Created by Wutian on 14/6/27.
//  Copyright (c) 2014年 Sina. All rights reserved.
//

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
