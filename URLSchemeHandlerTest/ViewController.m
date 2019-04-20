//
//  ViewController.m
//  URLSchemeHandlerTest
//
//  Created by liang on 2019/4/20.
//  Copyright © 2019 liang. All rights reserved.
//

#import "ViewController.h"

@import WebKit;

@interface ViewController () <WKURLSchemeHandler, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NSURL *url = [NSURL URLWithString:@"http://192.168.199.160:9999/index.html"];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:100]];
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"jsb://test.com/index.2.html"]];
//    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
//    [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL.URLByDeletingLastPathComponent];

    [self.view addSubview:self.webView];
}
#pragma mark - navigation

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSURLRequest *request = navigationAction.request;
    NSLog(@"URL = %@,Method = %@, body = %@, allKey = %@", request.URL,request.HTTPMethod, request.HTTPBody,[request.allHTTPHeaderFields allKeys]);
    decisionHandler(WKNavigationActionPolicyAllow);
}
#pragma mark - url task

- (void)webView:(WKWebView *)webView startURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask
{
    NSURLRequest *request = urlSchemeTask.request;

    NSLog(@"URL = %@,Method = %@, body = %@, allKey = %@", request.URL,request.HTTPMethod, request.HTTPBody,[request.allHTTPHeaderFields allKeys]);
    NSData *data = request.HTTPBody;
   
    if (data == nil) {
        NSError *err = [[NSError alloc] initWithDomain:@"自定义的资源无法解析" code:-4003 userInfo:nil];
        [urlSchemeTask didFailWithError:err];
    } else {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:@"text/plain" expectedContentLength:data.length textEncodingName:nil];
        [urlSchemeTask didReceiveResponse:response];
        [urlSchemeTask didReceiveData:data];
        [urlSchemeTask didFinish];
    }
}

- (void)webView:(nonnull WKWebView *)webView stopURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    //
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - getter
- (WKWebView *)webView
{
    if (_webView == nil) {
        //
        WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
        
        webViewConfig.allowsInlineMediaPlayback = YES;
        [webViewConfig setURLSchemeHandler:self forURLScheme:@"jsb"];

        CGRect size = [[UIScreen mainScreen] bounds];
        WKWebView *webview = [[WKWebView alloc] initWithFrame:size configuration:webViewConfig];
        webview.navigationDelegate = self;
        _webView = webview;
    }
    return _webView;
}
@end
