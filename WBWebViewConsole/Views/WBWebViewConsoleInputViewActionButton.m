//
//  WBWebViewConsoleInputViewActionButton.m
//  Weibo
//
//  Created by Wutian on 14/7/28.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "WBWebViewConsoleInputViewActionButton.h"
#import "UIColor+WBTHelpers.h"
#import "UIView+WBTSizes.h"
#import "WBWebViewConsoleDefines.h"

@interface WBWebViewConsoleInputActionPanel : UIImageView

@property (nonatomic, weak) WBWebViewConsoleInputViewActionButton * actionButton;

- (void)reloadData;

@property (nonatomic, strong) NSArray * buttons;

- (id)initWithActionButton:(WBWebViewConsoleInputViewActionButton *)actionButton;

- (void)highlightPoint:(CGPoint)point;
- (void)selectPoint:(CGPoint)point;

@end

@interface WBWebViewConsoleInputViewActionButton ()

@property (nonatomic, strong) UIImageView * iconImageView;
@property (nonatomic, strong) WBWebViewConsoleInputActionPanel * actionPanel;

@end

@implementation WBWebViewConsoleInputViewActionButton

- (void)dealloc
{
    
    [_actionPanel setActionButton:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userinput_actions.png" inBundle:WBWebBrowserConsoleBundle() compatibleWithTraitCollection:nil]];
        self.iconImageView.contentMode = UIViewContentModeCenter;
        
        [self addSubview:self.iconImageView];
        
        {
            UIPanGestureRecognizer * gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
            [self addGestureRecognizer:gesture];
        }
        
        {
            UILongPressGestureRecognizer * gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
            gesture.minimumPressDuration = 0.0;
            [self addGestureRecognizer:gesture];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.iconImageView.frame = self.bounds;
}

- (void)panGesture:(UIGestureRecognizer *)gestureRecognizer
{
    UIGestureRecognizerState state = gestureRecognizer.state;
    CGPoint point = [gestureRecognizer locationInView:self.actionPanel];
    
    switch (state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self showActionPanel];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            [self.actionPanel highlightPoint:point];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self.actionPanel selectPoint:point];
            [self hideActionPanel];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [self hideActionPanel];
            break;
        }
        default:
        break;
    }
}

#pragma mark - Action Panel

- (WBWebViewConsoleInputActionPanel *)actionPanel
{
    if (!_actionPanel)
    {
        _actionPanel = [[WBWebViewConsoleInputActionPanel alloc] initWithActionButton:self];
        _actionPanel.layer.zPosition = 10;
    }
    return _actionPanel;
}

- (void)showActionPanel
{
    if (!self.actionPanel.superview)
    {
        CGRect frame = CGRectMake(0, 0, 140, 198);
        frame.origin.x = self.wbtWidth - frame.size.width + 5;
        frame.origin.y = self.wbtHeight - frame.size.height + 10;
        
        frame = [self.window convertRect:frame fromView:self];
        
        _actionPanel.frame = frame;
        
        [self.window addSubview:_actionPanel];
    }
    
    [_actionPanel reloadData];
}

- (void)hideActionPanel
{
    [_actionPanel removeFromSuperview];
}

@end

@interface WBWebViewConsoleInputActionPanelButton : UIView

@property (nonatomic, assign) SEL selector;

@property (nonatomic, strong) UILabel * textLabel;
@property (nonatomic, strong) UIView * seperatorView;

@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) BOOL disabled;

@end

@interface WBWebViewConsoleInputActionPanel ()

@property (nonatomic, strong) UIView * buttonContainerView; // for corner radius

@end

@implementation WBWebViewConsoleInputActionPanel


- (id)initWithActionButton:(WBWebViewConsoleInputViewActionButton *)actionButton
{
    if (self = [super initWithFrame:CGRectZero])
    {
        self.actionButton = actionButton;
        
        self.image = [[UIImage imageNamed:@"userinput_action_panel.png" inBundle:WBWebBrowserConsoleBundle() compatibleWithTraitCollection:nil] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
        
        NSMutableArray * buttons = [NSMutableArray array];
        
        {
            WBWebViewConsoleInputActionPanelButton * button = [[WBWebViewConsoleInputActionPanelButton alloc] initWithFrame:CGRectZero];
            
            button.textLabel.text = NSLocalizedString(@"Toggle Keyboard", nil);
            button.selector = self.actionButton.dismissKeyboardSelector;
            
            [buttons addObject:button];
        }
        
        {
            WBWebViewConsoleInputActionPanelButton * button = [[WBWebViewConsoleInputActionPanelButton alloc] initWithFrame:CGRectZero];
            
            button.textLabel.text = NSLocalizedString(@"Next", nil);
            button.selector = self.actionButton.nextHistorySelector;
            
            [buttons addObject:button];
        }
        
        {
            WBWebViewConsoleInputActionPanelButton * button = [[WBWebViewConsoleInputActionPanelButton alloc] initWithFrame:CGRectZero];
            
            button.textLabel.text = NSLocalizedString(@"Previous", nil);
            button.selector = self.actionButton.previousHistorySelector;
            
            [buttons addObject:button];
        }
        
        {
            WBWebViewConsoleInputActionPanelButton * button = [[WBWebViewConsoleInputActionPanelButton alloc] initWithFrame:CGRectZero];
            
            button.textLabel.text = NSLocalizedString(@"New Line", nil);
            button.selector = self.actionButton.newlineSelector;
            button.seperatorView.hidden = YES;
            
            [buttons addObject:button];
        }
        
        self.buttons = buttons;
        
        self.buttonContainerView = [[UIView alloc] initWithFrame:self.bounds];
        self.buttonContainerView.layer.masksToBounds = YES;
        self.buttonContainerView.layer.cornerRadius = 6.0;
        
        [self addSubview:self.buttonContainerView];
    }
    return self;
}

- (void)reloadData
{
    [self layoutSubviews];
    
    CGFloat width = self.buttonContainerView.wbtWidth;
    CGFloat height = 36;
    CGFloat baseY = 0;
    
    for (WBWebViewConsoleInputActionPanelButton * button in _buttons)
    {
        [_buttonContainerView addSubview:button];
        
        button.frame = CGRectMake(0, baseY, width, height);
        baseY += height;
        
        button.disabled = ![self.actionButton.responder canPerformAction:button.selector withSender:self.actionButton];
        button.highlighted = NO;
        
        [button layoutSubviews];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.buttonContainerView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(4, 10, 45, 10));
}

- (void)highlightPoint:(CGPoint)point
{
    point = [_buttonContainerView convertPoint:point fromView:self];
    
    for (WBWebViewConsoleInputActionPanelButton * button in _buttons)
    {
        button.highlighted = (CGRectContainsPoint(button.frame, point));
    }
}

- (void)selectPoint:(CGPoint)point
{
    point = [_buttonContainerView convertPoint:point fromView:self];
    
    for (WBWebViewConsoleInputActionPanelButton * button in _buttons)
    {
        button.highlighted = NO;
        
        if (CGRectContainsPoint(button.frame, point))
        {
            if (!button.disabled)
            {
                [[UIApplication sharedApplication] sendAction:button.selector to:self.actionButton.responder from:self.actionButton forEvent:nil];
            }
            return;
        }
    }
}

@end

@implementation WBWebViewConsoleInputActionPanelButton


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textLabel];
        
        self.seperatorView = [[UIView alloc] initWithFrame:CGRectZero];
        self.seperatorView.backgroundColor = [UIColor wbt_colorWithHexValue:0xDFDFDF alpha:1.0];
        [self addSubview:self.seperatorView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = self.bounds;
    
    CGFloat height = 1 / [UIScreen mainScreen].scale;
    
    self.seperatorView.frame = CGRectMake(0, self.wbtHeight - height, self.wbtWidth, height);
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (_highlighted != highlighted)
    {
        _highlighted = highlighted;
        
        [self updateStates];
    }
}

- (void)setDisabled:(BOOL)disabled
{
    if (_disabled != disabled)
    {
        _disabled = disabled;
        
        [self updateStates];
    }
}

- (void)updateStates
{
    self.backgroundColor = (!_disabled && _highlighted) ? [UIColor wbt_colorWithHexValue:0x0076FF alpha:1.0] : [UIColor clearColor];
    self.textLabel.textColor = _disabled ? [UIColor wbt_colorWithHexValue:0xBDBDBD alpha:1.0] : (_highlighted ? [UIColor whiteColor] : [UIColor wbt_colorWithHexValue:0x565656 alpha:1.0]);
}

@end
