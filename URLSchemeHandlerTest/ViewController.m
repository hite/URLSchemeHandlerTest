//
//  ViewController.m
//  URLSchemeHandlerTest
//
//  Created by liang on 2019/4/20.
//  Copyright © 2019 liang. All rights reserved.
//

#import "ViewController.h"
#import "WebConfig.h"
@import WebKit;

@interface ViewController () <WKURLSchemeHandler, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 所以的测试数据，需要打开 Safari 的 开发者工具来看。打开和刷新 http://localhost:9999
    // 需要在 index.html 文件启动 webserver 如；python -m SimpleHTTPServer 9999
    NSURL *url = [NSURL URLWithString:@"about:blank"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataDontLoad timeoutInterval:1000]];
    
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
    NSURLRequest *request = navigationAction.request;
    NSLog(@"decidePolicyForNavigationAction. URL = %@,Method = %@, body = %@, allKey = %@", request.URL,request.HTTPMethod, request.HTTPBody,[request.allHTTPHeaderFields allKeys]);
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - url task
static NSData *kCached = nil;
- (void)webView:(WKWebView *)webView startURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask
{
    NSURLRequest *request = urlSchemeTask.request;

    NSLog(@"URL = %@,Method = %@, body = %@, allKey = %@", request.URL,request.HTTPMethod, request.HTTPBody,[request.allHTTPHeaderFields allKeys]);
    NSString *jsFile = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"jsb://" withString:@""];
    
    if (kCached == nil) {
        kCached = [NSData dataWithContentsOfURL:[[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:jsFile]];
    }
   
    if (kCached == nil) {
        NSError *err = [[NSError alloc] initWithDomain:@"自定义的资源无法解析" code:-4003 userInfo:nil];
        [urlSchemeTask didFailWithError:err];
    } else {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:@"text/plain" expectedContentLength:kCached.length textEncodingName:nil];
        [urlSchemeTask didReceiveResponse:response];
        [urlSchemeTask didReceiveData:kCached];
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
        WKWebViewConfiguration *webViewConfig = [WebConfig getInst];
        [webViewConfig setURLSchemeHandler:self forURLScheme:@"jsb"];

        CGRect size = [[UIScreen mainScreen] bounds];
        WKWebView *webview = [[WKWebView alloc] initWithFrame:size configuration:webViewConfig];
        webview.navigationDelegate = self;
        _webView = webview;
    }
    return _webView;
}
@end
