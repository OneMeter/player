//
//  UIView+getGect.m
//  Net笔记-屏幕适配
//
//  Created by 小川 on 15-11-27.
//  Copyright (c) 2015年 iChuan. All rights reserved.
//
//#define IPhone4s ((SCREEN_WIDTH == 320) && (SCREEN_HEIGHT == 480))
//#define IPhone5s ((SCREEN_WIDTH == 320) && (SCREEN_HEIGHT == 568))
//#define IPhone6 ((SCREEN_WIDTH == 375) && (SCREEN_HEIGHT == 667))
//#define IPhone6Plus ((SCREEN_WIDTH == 414) && (SCREEN_HEIGHT == 736))
#import "UIView+getGect.h"
#import "ZJCPublicDefine.h"

@implementation UIView (getGect)

+ (CGRect)getRectWithX:(CGFloat)x Y:(CGFloat)y width:(CGFloat)width andHeight:(CGFloat)height{
    CGRect rect = CGRectZero;
    if (IPhone4s) {
        rect = CGRectMake(x * (320 / 414.0), y * (480 / 736.0), width * (320 / 414.0), height * (480 / 736.0));
    }else if (IPhone5s) {
        rect = CGRectMake(x * (320 / 414.0), y * (568 / 736.0), width * (320 / 414.0), height * (568 / 736.0));
    }else if (IPhone6){
        rect = CGRectMake(x * (375 / 414.0), y * (667 / 736.0), width * (375 / 414.0), height * (667 / 736.0));
    }else if(IPhone6Plus){
        rect = CGRectMake(x , y , width, height);
    }
    return rect;
}

@end
