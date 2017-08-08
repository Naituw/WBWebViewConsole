//
//  WBWebDebugConsoleViewController.m
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

#import "WBWebDebugConsoleViewController.h"
#import "WBWebViewConsole.h"
#import "WBWebViewConsoleMessageCell.h"
#import "WBWebViewConsoleInputView.h"
#import "UIScrollView+WBTUtilities.h"
#import "UIView+WBTSizes.h"
#import "WBKeyboardObserver.h"

@interface WBWebDebugConsoleViewController () <UITableViewDataSource, UITableViewDelegate, WBWebViewConsoleInputViewDelegate, WBWebViewConsoleMessageCellDelegate>

@property (nonatomic, strong) WBWebViewConsole * console;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) WBWebViewConsoleInputView * inputView;

@property (nonatomic, strong) NSLayoutConstraint * inputViewHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint * bottomConstraint;
@end

@implementation WBWebDebugConsoleViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithConsole:(WBWebViewConsole *)console
{
    if (self = [self init]) {
        self.console = console;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Debug Console", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChangeNotification:) name:WBKeyboardObserverFrameDidUpdateNotification object:nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", nil) style:UIBarButtonItemStylePlain target:self action:@selector(clearMessages)];
    
    self.inputView = [[WBWebViewConsoleInputView alloc] initWithFrame:CGRectZero];
    [self.inputView setDelegate:self];
    [self.inputView setFont:[WBWebViewConsoleMessageCell messageFont]];
    [self.inputView setConsole:self.console];
    self.inputView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.inputView];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:@{@"tableView":self.tableView}]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[inputView]|" options:0 metrics:nil views:@{@"inputView":self.inputView}]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView][inputView]" options:0 metrics:nil views:@{@"tableView":self.tableView, @"inputView":self.inputView}]];
    [NSLayoutConstraint activateConstraints:constraints];
    
    self.inputViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.inputView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.inputView.desiredHeight];
    self.inputViewHeightConstraint.active = YES;
    
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.inputView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    self.bottomConstraint.active = YES;
    
    if (self.initialCommand.length)
    {
        [self.inputView setText:self.initialCommand];
        [self.inputView.textView becomeFirstResponder];
    }
}

- (void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)setConsole:(WBWebViewConsole *)console
{
    if (_console != console)
    {
        [self unregisterConsoleNotifications];
        
        _console = console;
        
        [self registerNotificationsForCurrentConsole];
    }
}

- (CGFloat)keyboardHeight
{
    CGRect endFrame = [WBKeyboardObserver sharedObserver].frameEnd;
    
    if (CGRectIsNull(endFrame))
    {
        return 0;
    }
    
    return MAX([UIScreen mainScreen].bounds.size.height - endFrame.origin.y, 0);
}

- (void)viewDidLayoutSubviews {
    //    [self.view setNeedsUpdateConstraints];
    CGFloat keyboardHeight = [self keyboardHeight];
    
    CGRect absolutePosition = [self.view convertRect:self.view.bounds toView:self.view.window];
    
    CGFloat bottomHeight = CGRectGetMaxY(absolutePosition);
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomConstraint.constant = MAX(bottomHeight - (self.view.window.wbtHeight - keyboardHeight), 0);
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2; // cleared messages + messages
}

- (NSArray *)messageDatasourceForSection:(NSInteger)section
{
    if (section == 0)
    {
        return _console.clearedMessages;
    }
    else
    {
        return _console.messages;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self messageDatasourceForSection:section].count;
}

- (WBWebViewConsoleMessage *)messageAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * datasource = [self messageDatasourceForSection:indexPath.section];
    
    if (indexPath.row >= datasource.count)
    {
        return nil;
    }
    
    return datasource[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WBWebViewConsoleMessage * message = [self messageAtIndexPath:indexPath];
    
    return [WBWebViewConsoleMessageCell rowHeightOfDataObject:message tableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const identifier = @"WBWebViewConsoleMessageCell";
    WBWebViewConsoleMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[WBWebViewConsoleMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.message = [self messageAtIndexPath:indexPath];
    cell.cleared = indexPath.section == 0;
    cell.delegate = self;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:))
    {
        WBWebViewConsoleMessage * message = [self messageAtIndexPath:indexPath];
        
        if (message)
        {
            [UIPasteboard generalPasteboard].string = message.message;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)consoleMessageCell:(WBWebViewConsoleMessageCell *)cell copyMessageToInputView:(WBWebViewConsoleMessage *)message
{
    self.inputView.text = message.message;
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    if (self.inputView.bottom < self.view.height)
//    {
//        [self.view endEditing:YES];
//    }
//}

#pragma mark - Console Notifications

- (void)registerNotificationsForCurrentConsole
{
    if (!_console) return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(consoleDidAddMessage:) name:WBWebViewConsoleDidAddMessageNotification object:_console];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(consoleDidClearMessages:) name:WBWebViewConsoleDidClearMessagesNotification object:_console];
}
- (void)unregisterConsoleNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WBWebViewConsoleDidAddMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WBWebViewConsoleDidClearMessagesNotification object:nil];
}

- (void)consoleDidAddMessage:(NSNotification *)notification
{
    BOOL scrollToBottom = self.tableView.wbt_isScrolledToBottom;
    
    [self.tableView reloadData];

    if (scrollToBottom)
    {
        [self.tableView wbt_scrollToBottomAnimated:NO];
    }
}
- (void)consoleDidClearMessages:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)clearMessages
{
    [self.console clearMessages];
}

#pragma mark - InputView Delegate

- (void)consoleInputViewHeightChanged:(WBWebViewConsoleInputView *)inputView
{
    self.inputViewHeightConstraint.constant = self.inputView.desiredHeight;
}

- (void)consoleInputViewDidBeginEditing:(WBWebViewConsoleInputView *)inputView
{
    [self.tableView wbt_scrollToBottomAnimated:YES];
}

- (void)consoleInputView:(WBWebViewConsoleInputView *)inputView didCommitCommand:(NSString *)command
{
    [self.tableView wbt_scrollToBottomAnimated:NO];
}

#pragma mark - Keyboard Notification

- (void)keyboardFrameDidChangeNotification:(NSNotification *)notification
{
    CGFloat keyboardHeight = [self keyboardHeight];
    
    CGRect absolutePosition = [self.view convertRect:self.view.bounds toView:self.view.window];
    
    CGFloat bottomHeight = CGRectGetMaxY(absolutePosition);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomConstraint.constant = MAX(bottomHeight - (self.view.window.wbtHeight - keyboardHeight), 0);
        [self.view layoutIfNeeded];
    }];
}

@end
