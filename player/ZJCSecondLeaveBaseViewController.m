//
//  ZJCSecondLeaveBaseViewController.m
//  CCRA
//
//  Created by htkg on 16/2/24.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCSecondLeaveBaseViewController.h"

@interface ZJCSecondLeaveBaseViewController ()

@end

@implementation ZJCSecondLeaveBaseViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化
    [self selfInitInitSecondLeaveVC];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 隐藏掉状态栏,下面有对应自调方法
     
    // 设置状态栏的类型
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"内存告急处理!");
}

// 隐藏状态栏
- (BOOL)prefersStatusBarHidden{
    return YES;
}

// 设置状态栏的类型
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



#pragma mark - 初始化
- (void)selfInitInitSecondLeaveVC{
    
}

@end
