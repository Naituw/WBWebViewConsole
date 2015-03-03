//
//  NSObject+WBJSONKit.h
//  WBWebViewConsole
//
//  Created by 吴天 on 15/3/3.
//  Copyright (c) 2015年 Sina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (WBJSONKit)

@end

@interface NSString (WBJSONKit)

@property (nonatomic, copy, readonly) NSString * wb_JSONString;
@property (nonatomic, copy, readonly) id wb_objectFromJSONString;

@end

@interface NSArray (WBJSONKit)

@property (nonatomic, copy, readonly) NSString * wb_JSONString;

@end

@interface NSDictionary (WBJSONKit)

@property (nonatomic, copy, readonly) NSString * wb_JSONString;

@end

