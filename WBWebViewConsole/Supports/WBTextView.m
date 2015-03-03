//
//  WBTextView.m
//  Weibo
//
//  Created by Stephen Liu on 14-3-12.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "WBTextView.h"
#import "UIDevice+WBTHelpers.h"
#import "UIView+WBTSizes.h"

@interface WBTextView ()
{
	NSInteger minHeight;
	NSInteger maxHeight;
    BOOL inited;
}
- (void)textViewDidChange:(UITextView *)textView;
@end

@interface WBTextViewDelegateProxy : NSObject<UITextViewDelegate>
@property (nonatomic, weak)WBTextView *textView;
@end

@implementation WBTextViewDelegateProxy

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([[_textView textDelegate] respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
        return [[_textView textDelegate] textViewShouldBeginEditing:textView];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([[_textView textDelegate] respondsToSelector:@selector(textViewShouldEndEditing:)]) {
        return [[_textView textDelegate] textViewShouldEndEditing:textView];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([[_textView textDelegate] respondsToSelector:@selector(textViewDidBeginEditing:)]) {
        [[_textView textDelegate] textViewDidBeginEditing:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([[_textView textDelegate] respondsToSelector:@selector(textViewDidEndEditing:)]) {
        [[_textView textDelegate] textViewDidEndEditing:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([[_textView textDelegate] respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        return [[_textView textDelegate] textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [_textView textViewDidChange:textView];
    if ([[_textView textDelegate] respondsToSelector:@selector(textViewDidChange:)]) {
        [[_textView textDelegate] textViewDidChange:textView];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if ([[_textView textDelegate] respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [[_textView textDelegate] textViewDidChangeSelection:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if ([[_textView textDelegate] respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)]) {
        return [[_textView textDelegate] textView:textView shouldInteractWithURL:URL inRange:characterRange];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    if ([[_textView textDelegate] respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)]) {
        return [[_textView textDelegate] textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
    }
    return YES;
}

@end

@implementation WBTextView
{
    UILabel *placeHolderLabel;
    WBTextViewDelegateProxy *proxyDelegate;
    
}
@synthesize minHeight;
@synthesize maxHeight;
- (void)dealloc
{
    proxyDelegate = nil;
    placeHolderLabel = nil;
}

- (void)setDelegate:(id<UITextViewDelegate>)delegate
{
    if ([delegate conformsToProtocol:@protocol(WBTextViewDelegate)]) {
        self.textDelegate = (id<WBTextViewDelegate>)delegate;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        minHeight = self.font.lineHeight;
        maxHeight = NSIntegerMax;
        
        proxyDelegate = [[WBTextViewDelegateProxy alloc] init];
        proxyDelegate.textView = self;
        
        [super setDelegate:proxyDelegate];
    }
    inited = YES;
    return self;
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    [self placeHolderLabel].text = placeHolder;
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor
{
    [self placeHolderLabel].textColor = placeHolderColor;
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self placeHolderLabel].font = font;
    [self checkPlaceHolderState];
}

- (UILabel *)placeHolderLabel
{
    if(!placeHolderLabel){
        CGRect frame = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
        IF_IOS7_OR_GREATER(
                           frame = UIEdgeInsetsInsetRect(frame, self.textContainerInset);
        );
        placeHolderLabel = [[UILabel alloc] initWithFrame:frame];
        placeHolderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        placeHolderLabel.backgroundColor = [UIColor clearColor];
        placeHolderLabel.numberOfLines = 0;
        placeHolderLabel.font = self.font;
        [self addSubview:placeHolderLabel];
        placeHolderLabel.hidden = YES;
        placeHolderLabel.isAccessibilityElement = NO;
    }
    return placeHolderLabel;
}

- (void)showPlaceHolder:(BOOL)show
{
    if (show) {
        [self placeHolderLabel].hidden = NO;
        [self bringSubviewToFront:placeHolderLabel];
        placeHolderLabel.userInteractionEnabled = NO;
        placeHolderLabel.frame = CGRectMake(5 + (WBAvalibleOS(7)?0:5), 8, self.bounds.size.width - (5 + (WBAvalibleOS(7)?0:5))*2, 50);
        placeHolderLabel.wbtHeight = [placeHolderLabel.text sizeWithFont:placeHolderLabel.font constrainedToSize:CGSizeMake(placeHolderLabel.wbtWidth, 1000)].height;
    } else {
        placeHolderLabel.hidden = YES;
    }
}

- (void)checkPlaceHolderState
{
    [self showPlaceHolder:self.text.length == 0];
}

- (void)setWraperWithScrollView:(BOOL)wraperWithScrollView
{
    _wraperWithScrollView = wraperWithScrollView;
    if (_wraperWithScrollView) {
        self.bounces = NO;
//        self.scrollEnabled = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
    } else {
//        self.scrollEnabled = YES;
        self.bounces = YES;
        self.showsVerticalScrollIndicator = YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self checkPlaceHolderState];
//    [self scrollRangeToVisible:self.selectedRange];
}

- (void)scrollRangeToVisible:(NSRange)range
{
    CGRect rect = [self caretRectForPosition:self.selectedTextRange.start];
    [self scrollRectToVisible:rect animated:NO];
}

- (int)numberOfLines
{
	CGFloat height = self.contentSize.height;
	IF_IOS7_OR_GREATER(
					   CGFloat containerWidth = self.frame.size.width - self.contentInset.left - self.contentInset.right;
					   CGRect rect = [self.text boundingRectWithSize:CGSizeMake(containerWidth, CGFLOAT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:self.font}
                                                             context:nil];
					   height = rect.size.height;
                       )
	return (int)floor(height / self.font.lineHeight);
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    if (_wraperWithScrollView && [self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView * superScrollView = (UIScrollView *)self.superview;
        CGRect rectInsuperView = [self convertRect:rect toView:superScrollView];
        CGRect result = CGRectInset(rectInsuperView, 0, -20);
        result = CGRectIntersection(result, self.frame);
        
        if (CGRectIsNull(result)) result = rectInsuperView;
        
        [(UIScrollView *)self.superview scrollRectToVisible:result animated:animated];
    }
    else
    {
        [super scrollRectToVisible:rect animated:animated];
    }
}

- (void)setContentOffset:(CGPoint)s
{
    if (_wraperWithScrollView) {
        [super setContentOffset:CGPointMake(-self.contentInset.left, -self.contentInset.top)];
    } else {
        [super setContentOffset:s];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    if (_wraperWithScrollView) {
        [super setContentOffset:CGPointMake(-self.contentInset.left, -self.contentInset.top) animated:NO];
    } else {
        [super setContentOffset:contentOffset animated:animated];
    }
}

- (void)setContentSize:(CGSize)contentSize
{
    if (contentSize.height < self.font.lineHeight) {
        return;
    }
    BOOL changed = ABS(self.contentSize.height - contentSize.height) > 0.01;
    [super setContentSize:contentSize];
	
    if (changed) {
        [self textViewDidChangeSize];
    }
    if (WBAvalibleOS(7)) {
        if ([self isFirstResponder]) {
            [self scrollRangeToVisible:self.selectedRange];
        }
    }
}

- (void)setContentInset:(UIEdgeInsets)s
{
    UIEdgeInsets insets = s;
    
    if (s.bottom > 8)
    {
        insets.bottom = 8;
    }
    insets.top = 0;
    
    [super setContentInset:insets];
}

- (void)resizeTextView:(NSInteger)newSizeH
{
    if ([_textDelegate respondsToSelector:@selector(textView:willChangeHeight:)])
    {
        [_textDelegate textView:self willChangeHeight:newSizeH];
    }
    self.wbtHeight = newSizeH;
}

- (void)textViewDidChangeSize
{
    if (!inited) {
        return;
    }
    //size of content, so we can set the frame of self
    NSInteger newSizeH = self.contentSize.height;
    
    if (newSizeH <= minHeight)
    {
        newSizeH = minHeight;
    }
    
    if (self.frame.size.height >= maxHeight && newSizeH >= maxHeight)
    {
        newSizeH = maxHeight;                                               // not taller than maxHeight
    }
    
    if (self.frame.size.height != newSizeH)
    {
        if (newSizeH >= maxHeight)
        {
            self.wraperWithScrollView = NO;
        }
        else
        {
            self.wraperWithScrollView = YES;
        }
        
        if (newSizeH > maxHeight && self.frame.size.height <= maxHeight)
        {
            newSizeH = maxHeight;
        }
		
        if (newSizeH <= maxHeight)
        {
            if (_animateHeightChange)
            {
                [UIView animateWithDuration:0.1f
                                      delay:0
                                    options:(UIViewAnimationOptionAllowUserInteraction |
                                             UIViewAnimationOptionBeginFromCurrentState)
                                 animations:^(void) {
                                     [self resizeTextView:newSizeH];
                                 }
                                 completion:^(BOOL finished) {
                                     if ([_textDelegate respondsToSelector:@selector(textViewHeightChanged:)])
                                     {
                                         [_textDelegate textViewHeightChanged:self];
                                     }
                                 }
                 ];
            }
            else
            {
                [self resizeTextView:newSizeH];
                if ([_textDelegate respondsToSelector:@selector(textViewHeightChanged:)])
                {
                    [_textDelegate textViewHeightChanged:self];
                }
            }
        }
    }
}

- (void)setMaxNumberOfLines:(NSInteger)n
{
    NSString *newText = @"|W中|";
    for (int i = 1; i < n; ++i)
    {
        newText = [newText stringByAppendingString:@"\n|W中|"];
    }
    if (WBAvalibleOS(7)) {
		CGRect rect = [newText boundingRectWithSize:CGSizeMake(100, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:self.font}
                                            context:nil];
		maxHeight = rect.size.height;
        maxHeight += self.textContainerInset.top + self.textContainerInset.bottom;
    } else {
        maxHeight = [newText sizeWithFont:self.font
                        constrainedToSize:CGSizeMake(100, CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByCharWrapping].height;
        maxHeight += self.contentInset.top + self.contentInset.bottom + 5;
    }
    _maxNumberOfLines = n;
}

- (void)setMinNumberOfLines:(NSInteger)m
{
    NSString *newText = @"|W中|";
    
    for (int i = 1; i < m; ++i)
    {
        newText = [newText stringByAppendingString:@"\n|W中|"];
    }
    
    if (WBAvalibleOS(7)) {
		CGRect rect = [newText boundingRectWithSize:CGSizeMake(100, CGFLOAT_MAX)
											options:NSStringDrawingUsesLineFragmentOrigin
										 attributes:@{NSFontAttributeName:self.font}
											context:nil];
		minHeight = rect.size.height;
        minHeight += self.textContainerInset.top + self.textContainerInset.bottom;
    } else {
        minHeight = [newText sizeWithFont:self.font
                        constrainedToSize:CGSizeMake(100, CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByCharWrapping].height;
        minHeight += self.contentInset.top + self.contentInset.bottom + 5;
    }
    _minNumberOfLines = m;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self checkPlaceHolderState];
}

- (void)didMoveToSuperview
{
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        self.wraperWithScrollView = YES;
    } else {
        self.wraperWithScrollView = NO;
    }
}

- (NSString *)accessibilityLabel
{
    if (!self.text.length)
    {
        return placeHolderLabel.text;
    }
    return [super accessibilityLabel];
}

@end
