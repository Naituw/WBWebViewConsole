//
//  WBWebViewConsoleInputHistoryEntry.m
//  Weibo
//
//  Created by Wutian on 14/7/27.
//  Copyright (c) 2014年 Sina. All rights reserved.
//

#import "WBWebViewConsoleInputHistoryEntry.h"

@interface WBWebViewConsoleInputHistoryEmptyEntry : WBWebViewConsoleInputHistoryEntry

@end

@interface WBWebViewConsoleInputHistoryEntry ()

@property (nonatomic, copy) NSString * text;
@property (nonatomic, assign) NSRange cursor;

@end

@implementation WBWebViewConsoleInputHistoryEntry


- (instancetype)init
{
    if (self = [super init])
    {
        _cursor = NSMakeRange(NSNotFound, 0);
    }
    return self;
}

+ (instancetype)emptyEntry
{
    return [WBWebViewConsoleInputHistoryEmptyEntry new];
}
+ (instancetype)entryWithText:(NSString *)text cursor:(NSRange)cursor
{
    WBWebViewConsoleInputHistoryEntry * entry = [WBWebViewConsoleInputHistoryEntry new];
    entry.text = text;
    entry.cursor = cursor;
    
    return entry;
}

- (BOOL)isEmpty
{
    return NO;
}

@end

@implementation WBWebViewConsoleInputHistoryEmptyEntry

- (BOOL)isEmpty
{
    return YES;
}

@end
