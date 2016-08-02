//
//  ZJCHttpRequestErrorViews.m
//  CCRA
//
//  Created by htkg on 16/5/13.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCHttpRequestErrorViews.h"

@interface ZJCHttpRequestErrorViews ()

@property (nonatomic ,strong) UIView * backView;              // 底板
@property (nonatomic ,strong) UIImageView * errorImageView;   // 提示图片
@property (nonatomic ,strong) UILabel * errorLabel;           // 提示文字
@property (nonatomic ,strong) UIButton * requestRepetButton;  // 重新请求按钮

@end


@implementation ZJCHttpRequestErrorViews

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        // 配置
        self.backgroundColor = [UIColor clearColor];
        [self configSelf];
    }
    return self;
}



// 配置
- (void)configSelf{
    // 底板
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, [ZJCFrameControl GetControl_height:525])];
    self.backView.center = CGPointMake(self.width /2, self.height/2);
    self.backView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backView];
    
    // 提示图片
    self.errorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [ZJCFrameControl GetControl_weight:316], [ZJCFrameControl GetControl_height:204])];
    self.errorImageView.center = CGPointMake(self.center.x, [ZJCFrameControl GetControl_height:204]/2);
    self.errorImageView.image = [UIImage imageNamed:@"net_bad"];
    [self.backView addSubview:self.errorImageView];
    
    // 提示文字
    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, [ZJCFrameControl GetControl_height:60])];
    self.errorLabel.center = CGPointMake(self.center.x, CGRectGetMaxY(self.errorImageView.frame) + [ZJCFrameControl GetControl_Y:75]);
    self.errorLabel.text = @"网络出错了,请点击按钮重新加载";
    self.errorLabel.textColor = ZJCGetColorWith(210, 212, 216, 1);
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.font = [UIFont systemFontOfSize:14];
    [self.backView addSubview:self.errorLabel];
    
    // 重新请求按钮
    self.requestRepetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [ZJCFrameControl GetControl_weight:440], [ZJCFrameControl GetControl_height:115])];
    self.requestRepetButton.center = CGPointMake(self.center.x, CGRectGetMaxY(self.errorLabel.frame) + [ZJCFrameControl GetControl_Y:75]);
    
    [self.requestRepetButton setTitle:@"重新加载" forState:UIControlStateNormal];
    [self.requestRepetButton setTitleColor:THEME_BACKGROUNDCOLOR forState:UIControlStateNormal];
    self.requestRepetButton.layer.masksToBounds = YES;
    self.requestRepetButton.layer.borderColor = ZJCGetColorWith(210, 212, 216, 1).CGColor;
    self.requestRepetButton.layer.borderWidth = 2;
    
    [self.requestRepetButton addTarget:self action:@selector(requestRepetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.requestRepetButton];
}


- (void)requestRepetButtonClicked:(UIButton *)button{
    if (self.requestRepetButtonClicked) {
        self.requestRepetButtonClicked(button);
    }
}



@end
