//
//  UIColor+WBTHelpers.m
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//  Copyright (c) 2015 Sina. All rights reserved.
//

#import "UIColor+WBTHelpers.h"

@implementation UIColor (WBTHelpers)

+ (CGFloat)wbt_redColorFromHexRGBColor:(NSInteger)color
{
    return (((color & 0xff0000) >> 16) / 255.0);
}

+ (CGFloat)wbt_greenColorFromRGBColor:(NSInteger)color
{
    return (((color & 0x00ff00) >> 8) / 255.0);
}

+ (CGFloat)wbt_blueColorFromRGBColor:(NSInteger)color
{
    return ((color & 0x0000ff) / 255.0);
}

+ (UIColor *)wbt_colorWithHexValue:(NSInteger)color alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:[UIColor wbt_redColorFromHexRGBColor:color]
                           green:[UIColor wbt_greenColorFromRGBColor:color]
                            blue:[UIColor wbt_blueColorFromRGBColor:color]
                           alpha:alpha];
}

@end
