//
//  WBTestsUIWebView.h
//  WBWebViewConsole
//
//  Created by 吴天 on 15/3/1.
//  Copyright (c) 2015年 Sina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBWebView.h"

@interface WBTestsUIWebView : UIWebView <WBWebView>

- (BOOL)syncLoadHTMLString:(NSString *)html error:(NSError **)error;

@end
