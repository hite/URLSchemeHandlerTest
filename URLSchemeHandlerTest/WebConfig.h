//
//  WebConfig.h
//  URLSchemeHandlerTest
//
//  Created by liang on 2019/5/18.
//  Copyright © 2019 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WebKit;
NS_ASSUME_NONNULL_BEGIN

@interface WebConfig : NSObject

+(WKWebViewConfiguration *)getInst;

@end

NS_ASSUME_NONNULL_END
