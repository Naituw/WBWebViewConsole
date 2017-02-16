//
//  WBWebViewConsoleInputView.m
//  Weibo
//
//  Created by Wutian on 14/7/24.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "WBWebViewConsoleInputView.h"
#import "WBWebViewConsole.h"
#import "WBWebViewConsoleUserPromptCompletionDatasource.h"
#import "WBWebViewConsoleInputHistoryEntry.h"
#import "WBWebViewConsoleInputViewActionButton.h"
#import "UIDevice+WBTHelpers.h"
#import "UIView+WBTSizes.h"
#import "WBWebViewConsoleDefines.h"

NSUInteger const WBWebViewConsoleInputMaxHistorySize = 30;

@interface WBWebViewConsoleInputView () <WBTextViewDelegate>
{
    struct {
        unsigned int insertingNewLine: 1;
    } _flags;
}

@property (nonatomic, strong) UIImageView * iconImageView;
@property (nonatomic, strong) WBTextView * textView;
@property (nonatomic, strong) UIView * topBorderView;

@property (nonatomic, strong) UITableView * promptCompletionTableView;
@property (nonatomic, strong) WBWebViewConsoleUserPromptCompletionDatasource * promptCompletionDatasource;

@property (nonatomic, strong) NSMutableArray * history;
@property (nonatomic, assign) NSUInteger historyIndex;

@property (nonatomic, strong) WBWebViewConsoleInputViewActionButton * actionButton;

@end

@implementation WBWebViewConsoleInputView

- (void)dealloc
{
    
    [_promptCompletionTableView setDelegate:nil];
    [_promptCompletionTableView setDataSource:nil];
    [_promptCompletionDatasource setInputView:nil];

    
    
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];

        self.topBorderView = [[UIView alloc] initWithFrame:CGRectZero];
        self.topBorderView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        
        [self addSubview:self.topBorderView];
        
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.iconImageView.contentMode = UIViewContentModeCenter;
        self.iconImageView.image = [UIImage imageNamed:@"userinput_prompt.png" inBundle:WBWebBrowserConsoleBundle() compatibleWithTraitCollection:nil];
        
        [self addSubview:self.iconImageView];
        
        self.textView = [[WBTextView alloc] initWithFrame:CGRectZero];
        self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textView.returnKeyType = UIReturnKeyGo;
        self.textView.delegate = self;
        [self addSubview:self.textView];
        
        self.actionButton = [[WBWebViewConsoleInputViewActionButton alloc] initWithFrame:CGRectZero];
        self.actionButton.responder = self;
        self.actionButton.nextHistorySelector = @selector(nextHistory:);
        self.actionButton.previousHistorySelector = @selector(previousHistory:);
        self.actionButton.dismissKeyboardSelector = @selector(toggleKeyboard:);
        self.actionButton.newlineSelector = @selector(insertNewline:);
        [self addSubview:self.actionButton];
        
        [self restoreHistoryList];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsLayout];
    [self updatePromptTableViewFrame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.iconImageView.frame = CGRectMake(0, 0, 30, 36);
    self.topBorderView.frame = CGRectMake(0, 0, self.wbtWidth, 1.f / [UIScreen mainScreen].scale);
    
    CGFloat actionWidth = 40;
    self.actionButton.frame = CGRectMake(self.wbtWidth - actionWidth, self.wbtHeight - 36, actionWidth, 36);
    
    self.textView.frame = CGRectMake(25, 4, self.wbtWidth - actionWidth - 25, self.wbtHeight - 8);
}

- (void)setFont:(UIFont *)font
{
    self.textView.font = font;
    self.textView.maxNumberOfLines = 5;
}

- (void)setText:(NSString *)text
{
    self.textView.text = text;
}
- (NSString *)text
{
    return self.textView.text;
}

- (CGFloat)desiredHeight
{
    CGFloat height = self.textView.wbtHeight + 8;
    
    height = MAX(height, 36);
    
    return height;
}

- (WBTextView *)textView
{
    return _textView;
}

//- (void)didMoveToWindow
//{
//    [super didMoveToWindow];
//    
//    if (self.window)
//    {
//        [self.textView becomeFirstResponder];
//    }
//}

- (void)commitCurrentCommand
{
    NSString * command = _textView.text;
    
    if (![command stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) return;
    
    WBWebViewConsoleInputHistoryEntry * emptyEntry = [WBWebViewConsoleInputHistoryEntry new]; // not actual +[ emptyEntry];
    WBWebViewConsoleInputHistoryEntry * historyEntry = [self historyEntryForCurrentText];
    
    // Replace the previous entry if it does not have text or if the text is the same.
    WBWebViewConsoleInputHistoryEntry * previousEntry = [self historyEntryAtIndex:1];
    if (!previousEntry.isEmpty && (!previousEntry.text.length || [previousEntry.text isEqual:historyEntry.text]))
    {
        _history[1] = historyEntry;
        _history[0] = emptyEntry;
    }
    else
    {
        // Replace the first history entry and push a new empty one.
        _history[0] = historyEntry;
        [_history insertObject:emptyEntry atIndex:0];
        
        // Trim the history length if needed.
        if (_history.count > WBWebViewConsoleInputMaxHistorySize)
        {
             [_history removeObjectsInRange:NSMakeRange(WBWebViewConsoleInputMaxHistorySize, _history.count - WBWebViewConsoleInputMaxHistorySize)];
        }
    }
    
    _historyIndex = 0;
    _textView.text = nil;
    
    [self.console sendMessage:command];
    
    if ([_delegate respondsToSelector:@selector(consoleInputView:didCommitCommand:)])
    {
        [_delegate consoleInputView:self didCommitCommand:command];
    }
}

#pragma mark - TextView Delegate

- (void)textViewHeightChanged:(WBTextView *)textView
{
    if ([_delegate respondsToSelector:@selector(consoleInputViewHeightChanged:)])
    {
        [_delegate consoleInputViewHeightChanged:self];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([_delegate respondsToSelector:@selector(consoleInputViewDidBeginEditing:)])
    {
        [_delegate consoleInputViewDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self cancelPromptCompletion];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqual:@"\n"] && !_flags.insertingNewLine)
    {
        [self commitCurrentCommand];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length && textView.selectedRange.length == 0 && textView.isFirstResponder)
    {
        [self.console fetchSuggestionsForPrompt:textView.text cursorIndex:textView.selectedRange.location completion:^(NSArray *suggestions, NSRange replacementRange) {
            [self updatePromptCompletionWithSuggestions:suggestions replacementRange:replacementRange];
        }];
    }
    else
    {
        [self updatePromptCompletionWithSuggestions:nil replacementRange:NSMakeRange(NSNotFound, 0)];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [self textViewDidChange:textView];
}

#pragma mark - Prompt Completion

- (UITableView *)promptCompletionTableView
{
    if (!_promptCompletionTableView)
    {
        _promptCompletionTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _promptCompletionTableView.delegate = self.promptCompletionDatasource;
        _promptCompletionTableView.dataSource = self.promptCompletionDatasource;
        _promptCompletionTableView.bounces = NO;
        _promptCompletionTableView.separatorColor = [UIColor colorWithRed:0.82 green:0.84 blue:0.85 alpha:1];
    }
    return _promptCompletionTableView;
}
- (WBWebViewConsoleUserPromptCompletionDatasource *)promptCompletionDatasource
{
    if (!_promptCompletionDatasource)
    {
        _promptCompletionDatasource = [[WBWebViewConsoleUserPromptCompletionDatasource alloc] init];
        _promptCompletionDatasource.inputView = self;
    }
    return _promptCompletionDatasource;
}

- (void)updatePromptTableViewFrame
{
    CGFloat height = self.promptCompletionTableView.contentSize.height;
    height = MIN(height, 36 * 3);
    
    CGRect frameInWindow = [self.window convertRect:self.bounds fromView:self];
    
    self.promptCompletionTableView.frame = CGRectMake(0, CGRectGetMinY(frameInWindow) - height, CGRectGetWidth(frameInWindow), height);
}

- (void)updatePromptCompletionWithSuggestions:(NSArray *)suggestions replacementRange:(NSRange)replacementRange
{
    self.promptCompletionDatasource.suggestions = suggestions;
    self.promptCompletionDatasource.replacementRange = replacementRange;
    
    if (suggestions.count)
    {
        [self.promptCompletionTableView reloadData];
        [self.window addSubview:self.promptCompletionTableView];
        [self updatePromptTableViewFrame];
    }
    else
    {
        [self.promptCompletionTableView removeFromSuperview];
    }
}

- (void)cancelPromptCompletion
{
    [self updatePromptCompletionWithSuggestions:nil replacementRange:NSMakeRange(NSNotFound, 0)];
}

- (void)completePromptWithSuggestion:(NSString *)suggestion
{
    if (!suggestion.length) return;
    
    WBTextView * textView = _textView;
    NSString * text = textView.text;
    
    if (!text.length)
    {
        textView.text = suggestion;
        [self cancelPromptCompletion];
        return;
    }
    
    NSRange range = self.promptCompletionDatasource.replacementRange;
    range.location = MAX(0, range.location);
    range.location = MIN(text.length, range.location);
    range.length = MIN(range.length, text.length - range.location);
    
    UITextPosition * start = [textView positionFromPosition:[textView beginningOfDocument] offset:range.location];
    UITextPosition * end = [textView positionFromPosition:start offset:range.length];
    
    [textView replaceRange:[textView textRangeFromPosition:start toPosition:end] withText:suggestion];
    
    [self cancelPromptCompletion];
}

#pragma mark - History

- (void)restoreHistoryList
{
    // we can restore history from userDefaults here
    // but for now, just generates an empty array
    
    self.history = [NSMutableArray array];
    
    WBWebViewConsoleInputHistoryEntry * emptyEntry = [WBWebViewConsoleInputHistoryEntry emptyEntry];
    for (NSUInteger i = 0; i < WBWebViewConsoleInputMaxHistorySize; i++)
    {
        [_history addObject:emptyEntry];
    }
}

- (WBWebViewConsoleInputHistoryEntry *)historyEntryAtIndex:(NSUInteger)historyIndex
{
    if (historyIndex >= WBWebViewConsoleInputMaxHistorySize) return [WBWebViewConsoleInputHistoryEntry emptyEntry];
    
    return _history[historyIndex];
}

- (WBWebViewConsoleInputHistoryEntry *)historyEntryForCurrentText
{
    WBWebViewConsoleInputHistoryEntry * entry = [WBWebViewConsoleInputHistoryEntry entryWithText:_textView.text cursor:_textView.selectedRange];
    return entry;
}

- (void)rememberCurrentTextInHistory
{
    if (_historyIndex >= WBWebViewConsoleInputMaxHistorySize) return;
    
    [_history replaceObjectAtIndex:_historyIndex withObject:[self historyEntryForCurrentText]];
}

- (void)restoreHistoryEntry:(NSUInteger)historyIndex
{
    WBWebViewConsoleInputHistoryEntry * historyEntry = [self historyEntryAtIndex:historyIndex];
    
    _textView.text = historyEntry.text ? : @"";
    
    if (historyEntry.cursor.location != NSNotFound)
    {
        _textView.selectedRange = historyEntry.cursor;
    }
}

- (BOOL)hasPreviousHistory
{
    return ![[self historyEntryAtIndex:_historyIndex + 1] isEmpty];
}
- (BOOL)hasNextHistory
{
    return ![[self historyEntryAtIndex:_historyIndex - 1] isEmpty];
}

- (void)previousHistory:(id)sender
{
    if (![self hasPreviousHistory]) return;
    
    [self rememberCurrentTextInHistory];
    
    ++_historyIndex;
    
    [self restoreHistoryEntry:_historyIndex];
}
- (void)nextHistory:(id)sender
{
    if (![self hasNextHistory]) return;
    
    [self rememberCurrentTextInHistory];
    
    --_historyIndex;
    
    [self restoreHistoryEntry:_historyIndex];
}

- (void)handlePreviousKey:(id)sender
{
    if (!_textView.isFirstResponder) return;
    
    if (_textView.text.length)
    {
        // responds only if cursor on first line
        NSRange lineRange;
        [_textView.layoutManager lineFragmentRectForGlyphAtIndex:0 effectiveRange:&lineRange];
        if (_textView.selectedRange.location > lineRange.length || (_textView.selectionAffinity == UITextStorageDirectionForward && _textView.selectedRange.location == lineRange.length && _textView.selectedRange.location != _textView.text.length))
        {
            UITextPosition * position = [_textView positionFromPosition:_textView.selectedTextRange.start inDirection:UITextLayoutDirectionUp offset:1];
            UITextRange * range = [_textView textRangeFromPosition:position toPosition:position];
            [_textView setSelectedTextRange:range];
            return;
        }
    }
    
    [self previousHistory:sender];
}

- (void)handleNextKey:(id)sender
{
    if (!_textView.isFirstResponder) return;
    
    if (_textView.text.length)
    {
        // responds only if cursor on last line
        NSRange lineRange;
        [_textView.layoutManager lineFragmentRectForGlyphAtIndex:_textView.text.length - 1 effectiveRange:&lineRange];
        if (_textView.selectedRange.location < lineRange.location || (_textView.selectionAffinity == UITextStorageDirectionBackward && _textView.selectedRange.location == lineRange.location))
        {
            UITextPosition * position = [_textView positionFromPosition:_textView.selectedTextRange.start inDirection:UITextLayoutDirectionDown offset:1];
            UITextRange * range = [_textView textRangeFromPosition:position toPosition:position];
            [_textView setSelectedTextRange:range];
            return;
        }
    }
    
    [self nextHistory:sender];
}

#pragma mark - Key Commands

- (NSArray *)keyCommands
{
    IF_IOS7_OR_GREATER({
        UIKeyCommand * up = [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow modifierFlags:0 action:@selector(handlePreviousKey:)];
        UIKeyCommand * down = [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow modifierFlags:0 action:@selector(handleNextKey:)];
        UIKeyCommand * newline = [UIKeyCommand keyCommandWithInput:@"\r" modifierFlags:UIKeyModifierControl action:@selector(insertNewline:)]; // control+enter key
        return @[up, down, newline];
    })
    return nil;
}

#pragma mark - Actions

- (void)toggleKeyboard:(id)sender
{
    if (self.textView.isFirstResponder)
    {
        [self.textView resignFirstResponder];
    }
    else
    {
        [self.textView becomeFirstResponder];
    }
}

- (void)insertNewline:(id)sender
{
    _flags.insertingNewLine = YES;
    
    [self.textView insertText:@"\n"];
    
    _flags.insertingNewLine = NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(previousHistory:))
    {
        return [self hasPreviousHistory];
    }
    else if (action == @selector(nextHistory:))
    {
        return [self hasNextHistory];
    }
    else if (action == @selector(toggleKeyboard:))
    {
        return YES;
    }
    else if (action == @selector(insertNewline:))
    {
        return [self.textView isFirstResponder];
    }
    
    return [super canPerformAction:action withSender:sender];
}

@end
