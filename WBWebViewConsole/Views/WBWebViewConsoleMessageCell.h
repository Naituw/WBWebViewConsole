//
//  WBWebViewConsoleMessageCell.h
//  Weibo
//
//  Created by Wutian on 14/7/23.
//  Copyright (c) 2014年 Sina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WBWebViewConsoleMessage;
@protocol WBWebViewConsoleMessageCellDelegate;

@interface WBWebViewConsoleMessageCell : UITableViewCell

@property (nonatomic, strong) WBWebViewConsoleMessage * message;
@property (nonatomic, assign) BOOL cleared;

@property (nonatomic, weak) id<WBWebViewConsoleMessageCellDelegate> delegate;

+ (UIFont *)messageFont;
+ (CGFloat)rowHeightOfDataObject:(WBWebViewConsoleMessage *)message tableView:(UITableView *)tableView;

@end

@protocol WBWebViewConsoleMessageCellDelegate <NSObject>

- (void)consoleMessageCell:(WBWebViewConsoleMessageCell *)cell copyMessageToInputView:(WBWebViewConsoleMessage *)message;

@end