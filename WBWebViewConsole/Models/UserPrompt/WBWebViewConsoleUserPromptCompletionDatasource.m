//
//  WBWebViewConsoleUserPromptCompletionDatasource.m
//  Weibo
//
//  Created by Wutian on 14/7/25.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "WBWebViewConsoleUserPromptCompletionDatasource.h"
#import "WBWebViewConsoleMessageCell.h"
#import "WBWebViewConsoleInputView.h"
#import "UIColor+WBTHelpers.h"
#import "UIView+WBTSizes.h"

@interface WBWebViewConsoleUserPromptCompletionCell : UITableViewCell

@property (nonatomic, copy) NSString * suggestion;

@end

@implementation WBWebViewConsoleUserPromptCompletionDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _suggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const identifier = @"WBWebViewConsoleUserPromptCompletionCell";
    
    WBWebViewConsoleUserPromptCompletionCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[WBWebViewConsoleUserPromptCompletionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (indexPath.row < _suggestions.count)
    {
        cell.suggestion = _suggestions[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row < _suggestions.count)
    {
        [_inputView completePromptWithSuggestion:_suggestions[indexPath.row]];
    }
}

@end

@implementation WBWebViewConsoleUserPromptCompletionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.textLabel.font = [WBWebViewConsoleMessageCell messageFont];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.frame = CGRectMake(30, 0, self.wbtWidth - 40, self.wbtHeight);
}

- (void)setSuggestion:(NSString *)suggestion
{
    self.textLabel.text = suggestion;
}
- (NSString *)suggestion
{
    return self.textLabel.text;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    [self.contentView setBackgroundColor:highlighted ? RGBCOLOR(129, 137, 148) : [UIColor colorWithRed:0.69 green:0.72 blue:0.76 alpha:1]];
}

@end
