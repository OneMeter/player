//
//  ZJCBaseViewController.m
//  CCRA
//
//  Created by htkg on 16/2/24.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCBaseViewController.h"
#import <AFHTTPSessionManager.h>

@interface ZJCBaseViewController ()

@end

@implementation ZJCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 设置状态栏的类型
    [self setNeedsStatusBarAppearanceUpdate];
    
}

// 设置状态栏的类型
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





//- (BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return NO;
//}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
