//
//  ZJCTabBarViewController.h
//  Education
//
//  Created by htkg on 16/1/27.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJCTabBarViewController : UITabBarController

- (void)addViewControllerWithName:(NSString *)viewControllerName andTitle:(NSString *)title andNormalImage:(NSString *)image andSelectedImage:(NSString *)selectedImage;

@end
