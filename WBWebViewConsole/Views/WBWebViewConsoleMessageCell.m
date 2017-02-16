//
//  WBWebViewConsoleMessageCell.m
//  Weibo
//
//  Created by Wutian on 14/7/23.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "WBWebViewConsoleMessageCell.h"
#import "WBWebViewConsoleMessage.h"
#import "UIDevice+WBTHelpers.h"
#import "UIColor+WBTHelpers.h"
#import "UIView+WBTSizes.h"
#import "WBWebViewConsoleDefines.h"

@interface WBWebViewConsoleMessageCell ()

@property (nonatomic, strong) UILabel * messageLabel;
@property (nonatomic, strong) UILabel * callerLabel;

@property (nonatomic, strong) UIImageView * iconImageView;

@end

@implementation WBWebViewConsoleMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView * selectionView = [[UIView alloc] initWithFrame:CGRectZero];
        selectionView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        self.selectedBackgroundView = selectionView;
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.messageLabel.font = [[self class] messageFont];
        self.messageLabel.textColor = [UIColor blackColor];
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.wbtWidth = [UIScreen mainScreen].bounds.size.width - 40;
//        self.messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        [self.contentView addSubview:self.messageLabel];
        
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.iconImageView.contentMode = UIViewContentModeCenter;
        self.iconImageView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.iconImageView];
        
        self.callerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.callerLabel.font = [[self class] messageFont];
        self.callerLabel.backgroundColor = [UIColor clearColor];
        self.callerLabel.numberOfLines = 0;
        self.callerLabel.wbtWidth = [UIScreen mainScreen].bounds.size.width - 40;
//        self.callerLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        [self.contentView addSubview:self.callerLabel];
    }
    return self;
}

- (BOOL)usesCustomSelectedBackgroundView
{
    return NO;
}

+ (UIFont *)messageFont
{
    if (WBAvalibleOS(7))
    {
        return [UIFont fontWithName:@"Menlo" size:11];
    }
    return [UIFont fontWithName:@"Courier" size:11];
}

+ (CGFloat)rowHeightOfDataObject:(WBWebViewConsoleMessage *)message tableView:(UITableView *)tableView
{
    if (message.type == WBWebViewConsoleMessageTypeClear)
    {
        return 0;
    }
    
    CGFloat width = tableView.frame.size.width - 40;
    
    CGFloat height = 5; // top padding
    
    UIFont * font = [self messageFont];
    
    CGFloat messageHeight = ceil([message.message sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height);
    height += messageHeight;
    
    NSString * caller = message.caller;
    if (caller.length)
    {
        height += 2; // padding
        
        CGFloat callerHeight = ceil([message.caller sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height);
        height += callerHeight;
    }
    
    height += 5; // bottom padding
    
    return height;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.messageLabel.frame = CGRectMake(30, 5, self.frame.size.width - 40, self.messageLabel.wbtHeight);
    self.callerLabel.frame = CGRectMake(30, self.messageLabel.wbtBottom + 2, self.frame.size.width - 40, self.callerLabel.wbtHeight);
    self.iconImageView.frame = CGRectMake(0, 0, 30, 24);
}

//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
//{
//    [super setHighlighted:highlighted animated:animated];
//    
//    self.contentView.backgroundColor = highlighted ? [UIColor colorWithWhite:0.95 alpha:1.0] : [UIColor whiteColor];
//}

- (void)setMessage:(WBWebViewConsoleMessage *)message
{
    if (_message != message)
    {
        _message = message;
        
        self.messageLabel.text = message.message;
        self.callerLabel.text = message.caller;
        
        [self.messageLabel sizeToFit];
        [self.callerLabel sizeToFit];
        
        [self updateMessageStyle];
    }
}

- (void)setCleared:(BOOL)cleared
{
    if (_cleared != cleared)
    {
        _cleared = cleared;
        
        [self updateMessageStyle];
    }
}

- (void)updateMessageStyle
{
    UIColor * color = nil;
    NSString * iconName = nil;
    UIColor * callerColor = [UIColor grayColor];
    
    if (_cleared)
    {
        color = [UIColor colorWithWhite:0.0 alpha:0.2];
        callerColor = [UIColor colorWithWhite:0.0 alpha:0.15];
    }
    else
    {
        WBWebViewConsoleMessageLevel level = _message.level;
        WBWebViewConsoleMessageSource source = _message.source;
        
        if (source == WBWebViewConsoleMessageSourceUserCommand)
        {
            color = RGBCOLOR(77, 153, 255);
            iconName = @"userinput_prompt_previous";
        }
        else if (source == WBWebViewConsoleMessageSourceUserCommandResult)
        {
            color = RGBCOLOR(0, 80, 255);
            iconName = @"userinput_result";
        }
        else
        {
            switch (level) {
                case WBWebViewConsoleMessageLevelDebug:
                    color = [UIColor blueColor];
                    iconName = @"debug_icon";
                    break;
                case WBWebViewConsoleMessageLevelError:
                    color = [UIColor redColor];
                    iconName = @"error_icon";
                    break;
                case WBWebViewConsoleMessageLevelWarning:
                    color = [UIColor blackColor];
                    iconName = @"issue_icon";
                    if (source == WBWebViewConsoleMessageSourceNavigation)
                    {
                        iconName = @"navigation_issue_icon";
                        color = RGBCOLOR(246, 187, 14);
                    }
                    break;
                case WBWebViewConsoleMessageLevelNone:
                    color = [UIColor colorWithWhite:0.0 alpha:0.2];
                    break;
                case WBWebViewConsoleMessageLevelInfo:
                    color = [UIColor colorWithWhite:0.0 alpha:0.5];
                    iconName = @"info_icon";
                    break;
                case WBWebViewConsoleMessageLevelSuccess:
                    color = RGBCOLOR(0, 148, 10);
                    iconName = @"success_icon";
                    if (source == WBWebViewConsoleMessageSourceNavigation)
                    {
                        iconName = @"navigation_success_icon";
                    }
                    break;
                case WBWebViewConsoleMessageLevelLog:
                default:
                    color = [UIColor blackColor];
                    break;
            }
        }
        
        if ([_message.message isEqual:@"undefined"] ||
            [_message.message isEqual:@"null"])
        {
            if (source != WBWebViewConsoleMessageSourceUserCommand)
            {
                color = [UIColor colorWithWhite:0.0 alpha:0.3];
                callerColor = [UIColor colorWithWhite:0.0 alpha:0.2];
            }
        }
    }
    
    self.messageLabel.textColor = color;
    self.callerLabel.textColor = callerColor;
    self.iconImageView.image = nil;
    
    if (iconName)
    {
        self.iconImageView.image = [UIImage imageNamed:iconName inBundle:WBWebBrowserConsoleBundle() compatibleWithTraitCollection:nil];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:) || action == @selector(copyToInputView:));
}

- (void)copyToInputView:(id)sender
{
    if ([_delegate respondsToSelector:@selector(consoleMessageCell:copyMessageToInputView:)])
    {
        [_delegate consoleMessageCell:self copyMessageToInputView:_message];
    }
}

@end
