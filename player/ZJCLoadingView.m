//
//  ZJCLoadingView.m
//  CCRA
//
//  Created by htkg on 16/5/12.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCLoadingView.h"


@interface ZJCLoadingView ()

@property (nonatomic ,strong) UIImageView * animationView;     // 旋转视图
@property (nonatomic ,strong) UIImageView * logoView;          // logo视图

@end




@implementation ZJCLoadingView

// 初始化
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configSelf];
    }
    return self;
}


// 配置
- (void)configSelf{
    self.backgroundColor = [UIColor clearColor];
    
    // 旋转底图
    self.animationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    self.animationView.center = self.center;
    self.animationView.image = [UIImage imageNamed:@"loading_animation"];
    [self addSubview:self.animationView];
    
    // logo
    self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    self.logoView.center = self.center;
    self.logoView.image = [UIImage imageNamed:@"loading_logo"];
    [self addSubview:self.logoView];
}


- (void)showLoading{
    // 加载到window上去
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    // 动画
    CABasicAnimation* rotationAnimation;  
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];  
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];  
    rotationAnimation.duration = 1;  
    rotationAnimation.cumulative = YES;  
    rotationAnimation.repeatCount = MAXFLOAT;  
    
    [self.animationView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];  
}


- (void)dismissLoading{
    // 从主视图上干掉
    [self removeFromSuperview];
}



@end







//- (void)animationAction{
//    CGAffineTransform endAngle = CGAffineTransformMakeRotation(imageviewAngle * (M_PI / 180.0f));  
//    
//    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{  
//        imageView.transform = endAngle;  
//    } completion:^(BOOL finished) {  
//        angle += 10; [self startAnimation];  
//    }];
//}