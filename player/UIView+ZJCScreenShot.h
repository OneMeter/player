//
//  UIView+ZJCScreenShot.h
//  CCRA
//
//  Created by htkg on 16/4/7.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ZJCScreenShot)

/**
 根据当前控件 获取到一张对应的图片
 */
- (UIImage *)convertViewToImage;

@end
