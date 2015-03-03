//
//  WBWebViewJSBridgeTests.m
//  WBWebViewConsole
//
//  Created by 吴天 on 15/3/1.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "WBTestsUIWebView.h"
#import "WBJSBridgeAction.h"
#import "NSObject+WBJSONKit.h"

NSString * const WBJSBridgeFinishTestsNotification = @"WBJSBridgeFinishTestsNotification";

@interface WBJSBridgeActionGetValueTests : WBJSBridgeAction

@end

@interface WBJSBridgeActionFinishTests : WBJSBridgeAction

@end

@interface WBWebViewJSBridgeTests : XCTestCase

@end

@implementation WBWebViewJSBridgeTests

- (void)testJSBridgeInjection
{
    WBTestsUIWebView * webView = [[WBTestsUIWebView alloc] init];
    
    webView.JSBridge.interfaceName = @"JSBridge";
    
    XCTAssert([webView syncLoadHTMLString:@"Hello" error:NULL]);
    
    XCTAssert([[webView stringByEvaluatingJavaScriptFromString:@"typeof window.JSBridge"] isEqualToString:@"object"]);
}

- (void)testJSBridgeInvokeAndCallback
{
#define QUOTE(...) #__VA_ARGS__
    const char * html_char = QUOTE(
<!DOCTYPE html>
<html>
    <body>
    </body>
    <script>
        window.jserrors = [];
          
        window.addEventListener('error', function (event) {
            window.jserrors.push((event && event.message) || 'unknow error');
        }, false);
          
        function bridgeReady () {
            function finishTests (value) {
                var msg = {};
                if (value) {
                    msg = {'value': value};
                }
                JSBridge.invoke('finishTests', msg);
            }
            
            JSBridge.invoke('getValueTests'); /* tests no params, callback situation*/
            
            JSBridge.invoke('getValueTests', null, function (params, success) {
                if (success) {
                    finishTests(params && params['value']);
                } else {
                    finishTests();
                }
            });
        }
          
        if (window.JSBridge) {
            bridgeReady();
        } else {
            document.addEventListener('JSBridgeReady', bridgeReady, false);
        }
    </script>
</html>);
#undef QUOTE
    
    NSString * html = [NSString stringWithUTF8String:html_char];
    
    WBTestsUIWebView * webView = [[WBTestsUIWebView alloc] init];
    
    webView.JSBridge.interfaceName = @"JSBridge";
    webView.JSBridge.readyEventName = @"JSBridgeReady";
    
    XCTAssert([webView syncLoadHTMLString:html error:NULL]);
    
    [self expectationForNotification:WBJSBridgeFinishTestsNotification object:webView.JSBridge handler:^BOOL(NSNotification *notification) {

        NSString * errorJSON = [webView stringByEvaluatingJavaScriptFromString:@"JSON.stringify(window.jserrors)"];
        NSArray * errors = [errorJSON wb_objectFromJSONString];
        XCTAssertFalse(errors.count, @"errors: %@", errors);

        XCTAssertEqualObjects(notification.userInfo[@"value"], @"weibo.cn"); // see -[WBJSBridgeActionGetValueTests startAction]
        
        return YES;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:NULL];
}

@end

@implementation WBJSBridgeActionGetValueTests

- (void)startAction
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self actionSuccessedWithResult:@{@"value": @"weibo.cn"}];
    });
}

@end

@implementation WBJSBridgeActionFinishTests

- (void)startAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:WBJSBridgeFinishTestsNotification object:self.bridge userInfo:self.message.parameters];
    [self actionSuccessedWithResult:@{}];
}

@end
