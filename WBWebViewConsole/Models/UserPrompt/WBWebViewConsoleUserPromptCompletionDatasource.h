//
//  WBWebViewConsoleUserPromptCompletionDatasource.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class WBWebViewConsoleInputView;

@interface WBWebViewConsoleUserPromptCompletionDatasource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray * suggestions;
@property (nonatomic, assign) NSRange replacementRange;
@property (nonatomic, weak) WBWebViewConsoleInputView * inputView;

@end
