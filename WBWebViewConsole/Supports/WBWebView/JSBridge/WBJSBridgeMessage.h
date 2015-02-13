//
//  WBJSBridgeMessage.h
//  WBWebViewConsole
//
//  Created by 吴天 on 2/13/15.
//  Copyright (c) 2015 Sina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBJSBridgeMessage : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, copy, readonly) NSString * action;
@property (nonatomic, copy, readonly) NSDictionary * parameters;

@property (nonatomic, copy, readonly) NSString * callbackID;

@end
