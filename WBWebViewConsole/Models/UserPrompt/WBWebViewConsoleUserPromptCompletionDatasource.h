//
//  WBWebViewConsoleUserPromptCompletionDatasource.h
//  Weibo
//
//  Created by Wutian on 14/7/25.
//  Copyright (c) 2014年 Sina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class WBWebViewConsoleInputView;

@interface WBWebViewConsoleUserPromptCompletionDatasource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray * suggestions;
@property (nonatomic, assign) NSRange replacementRange;
@property (nonatomic, weak) WBWebViewConsoleInputView * inputView;

@end
