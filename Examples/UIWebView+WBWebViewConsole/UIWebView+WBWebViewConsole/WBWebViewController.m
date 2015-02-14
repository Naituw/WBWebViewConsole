//
//  WBWebViewController.m
//  UIWebView+WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//  Copyright (c) 2015 Sina. All rights reserved.
//

#import "WBWebViewController.h"
#import "WBUIWebView.h"
#import <WBWebViewConsole/WBWebViewConsole.h>
#import <WBWebViewConsole/WBWebDebugConsoleViewController.h>

@interface WBWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) WBUIWebView * webView;

@end

@implementation WBWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Browser";
    
    self.webView = [[WBUIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.wb_delegate = self;
    
    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://baidu.com"]]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Console" style:UIBarButtonItemStylePlain target:self action:@selector(showConsole:)];
}

- (void)showConsole:(id)sender
{
    WBWebDebugConsoleViewController * controller = [[WBWebDebugConsoleViewController alloc] initWithConsole:_webView.console];
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
