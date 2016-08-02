//
//  ZJCCourceInforView.m
//  CCRA
//
//  Created by htkg on 16/3/29.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCCourceInforView.h"



@interface ZJCCourceInforView ()

@property (nonatomic ,strong) UIWebView * webView;

@end




@implementation ZJCCourceInforView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        // 配置自己
        [self configSelf];
    }
    return self;
}


- (void)configSelf{
    _webView = [[UIWebView alloc] initWithFrame:self.bounds];
    [self addSubview:_webView];
    _webView.backgroundColor = [UIColor whiteColor];
}


- (void)setUrlString:(NSString *)urlString{
    if ([_urlString isKindOfClass:[NSNull class]]) {
        _urlString = @"";
    }
    _urlString = urlString;
    NSURL * url = [NSURL URLWithString:_urlString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}




@end
