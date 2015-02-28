//
//  UIScrollView+WBTUtilities.m
//  WBTool
//
//  Created by kevin on 14-7-18.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIScrollView+WBTUtilities.h"

@implementation UIScrollView (WBTUtilities)

- (BOOL)wbt_isScrolledToTop
{
	return self.contentOffset.y <= self.contentInset.top;
}

- (void)wbt_scrollToTopAnimated:(BOOL)animated
{
	[self setContentOffset:CGPointMake(0, -self.contentInset.top) animated:animated];
}

- (BOOL)wbt_isScrolledToBottom
{
	if (self.contentOffset.y >= self.contentSize.height - self.bounds.size.height)
	{
		return YES;
	}
	return NO;
}

- (void)wbt_scrollToBottomAnimated:(BOOL)animated
{
	CGRect rect = CGRectMake(self.contentOffset.x, self.contentSize.height - 1, self.contentSize.width, 1);
	[self scrollRectToVisible:rect animated:animated];
}

@end
