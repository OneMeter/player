//
//  ZJCNavigationViewController.m
//  CCRA
//
//  Created by htkg on 16/2/24.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCNavigationViewController.h"



@interface ZJCNavigationViewController ()

@end



@implementation ZJCNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 背景颜色
    [[UINavigationBar appearance] setBarTintColor:THEME_BACKGROUNDCOLOR];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    // 标题颜色
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//-(BOOL)shouldAutorotate{
//    return NO;
//    
//}
//
//
//-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    //return UIInterfaceOrientationMaskLandscapeRight;
//    return self.orietation;
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
//    return (interfaceOrientation != self.orietation);
//}


@end
