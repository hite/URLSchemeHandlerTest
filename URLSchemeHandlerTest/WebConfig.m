//
//  WebConfig.m
//  URLSchemeHandlerTest
//
//  Created by liang on 2019/5/18.
//  Copyright © 2019 liang. All rights reserved.
//

#import "WebConfig.h"


@implementation WebConfig

+(WKWebViewConfiguration *)getInst
{
    static dispatch_once_t onceToken;
    static WKWebViewConfiguration *webViewConfig;
    dispatch_once(&onceToken, ^{
        webViewConfig = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userController = [WKUserContentController new];
        Class WKUserStyleSheetClass = NSClassFromString(@"_WKUserStyleSheet");
        id userStyleSheet = [WKUserStyleSheetClass new];
        if ([userStyleSheet respondsToSelector:@selector(initWithSource:forMainFrameOnly:)]) {
            [userStyleSheet performSelector:@selector(initWithSource:forMainFrameOnly:) withObject:@"body{background-color:blue;}" withObject:@(YES)];
        }
        
        if ([userController respondsToSelector:@selector(_addUserStyleSheet:)]) {
            [userController performSelector:@selector(_addUserStyleSheet:) withObject:userStyleSheet];
        }
        // 测试 addUserScript 性能
        {
            WKUserScript *timeStart = [[WKUserScript alloc] initWithSource:@"console.time('a-h_userScript')" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
            [userController addUserScript:timeStart];
        }
        NSURL *dllURL = [[NSBundle mainBundle] URLForResource:@"dll" withExtension:@".js"];
        NSString *code = [NSString stringWithContentsOfURL:dllURL encoding:kCFStringEncodingUTF8 error:nil];
        WKUserScript *dlljs = [[WKUserScript alloc] initWithSource:code injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
        [userController addUserScript:dlljs];
        {
            WKUserScript *timeEnd = [[WKUserScript alloc] initWithSource:@"console.timeEnd('a-h_userScript')" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
            [userController addUserScript:timeEnd];
        }
        
        webViewConfig.userContentController = userController;
        webViewConfig.allowsInlineMediaPlayback = YES;
    });
    
    return webViewConfig;
}

@end
