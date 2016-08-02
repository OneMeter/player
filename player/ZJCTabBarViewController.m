//
//  ZJCTabBarViewController.m
//  Education
//
//  Created by htkg on 16/1/27.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCTabBarViewController.h"
#import "ZJCNavigationViewController.h"
#define ZJCGetColorWith(Red,Green,Blue,Alpha) [UIColor colorWithRed:(Red)/255. green:(Green)/255. blue:(Blue)/255. alpha:(Alpha)] 
#define THEME_BACKGROUNDCOLOR ZJCGetColorWith(94, 151, 227, 1)                        // 系统主色调  (淡蓝色)

@interface ZJCTabBarViewController ()

@end

@implementation ZJCTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 标签栏的颜色
//    self.tabBar.barTintColor = [UIColor colorWithWhite:0.96 alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)addViewControllerWithName:(NSString *)viewControllerName andTitle:(NSString *)title andNormalImage:(NSString *)normalImage andSelectedImage:(NSString *)selectedImage{
    // 获取类名,通过类名创建类
    Class class = NSClassFromString(viewControllerName);
    UIViewController * tempVC = [[class alloc] init];
    // 设置基本属性
    tempVC.title = title;
    // 缩放图片
    UIImage * image = [UIImage imageNamed:normalImage];
    NSData * data = UIImagePNGRepresentation(image);
    image = [UIImage imageWithData:data scale:2.2];
    UIImage * selectedimage = [UIImage imageNamed:selectedImage];
    NSData * selectedData = UIImagePNGRepresentation(selectedimage);
    selectedimage = [UIImage imageWithData:selectedData scale:2.2];
    // 保持图片原状
    tempVC.tabBarItem.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tempVC.tabBarItem.selectedImage = [selectedimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 设置标题栏属性的
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:10]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:THEME_BACKGROUNDCOLOR,NSFontAttributeName:[UIFont boldSystemFontOfSize:10]} forState:UIControlStateSelected];
    
    // 添加"导航"
    ZJCNavigationViewController * navTemp = [[ZJCNavigationViewController alloc] initWithRootViewController:tempVC];
    NSMutableArray * tempArray = [NSMutableArray arrayWithArray:self.viewControllers];
    [tempArray addObject:navTemp];
    self.viewControllers = tempArray;
}
@end
