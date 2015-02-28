//
//  UIScrollView+WBTUtilities.h
//  WBTool
//
//  Created by kevin on 14-7-18.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/*!
 *  本类主要提供了对UIScollview的相关操作
 */
@interface UIScrollView (WBTUtilities)

/*!
 *  判断当前contenView是否在顶部
 *
 *  @return 返回YES则当前是顶部，NO则不顶部
 */
- (BOOL)wbt_isScrolledToTop;

/*!
 *  将contenView移动至顶部
 *
 *  @param animated YES表示带动画效果，NO则不带
 */
- (void)wbt_scrollToTopAnimated:(BOOL)animated;

/*!
 *  判断当前contenView是否在底部
 *
 *  @return 返回YES则当前是底部，NO则不在底部
 */
- (BOOL)wbt_isScrolledToBottom;

/*!
 *  将contenView移动至底部
 *
 *  @param animated YES表示带动画效果，NO则不带
 */
- (void)wbt_scrollToBottomAnimated:(BOOL)animated;

@end
