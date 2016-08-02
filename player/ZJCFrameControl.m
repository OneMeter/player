//
//  ZJCFrameControl.m
//  CCRA
//
//  Created by htkg on 16/2/25.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCFrameControl.h"

@implementation ZJCFrameControl

// 控制x
+ (CGFloat)GetControl_X:(NSInteger)x{
    if (IPhone4s) {
        return x * (IPhone6Plus_SCREEN_WIDTH / 1080.0f) * (320.0 / 414.0);
    }
    return x * (SCREEN_WIDTH / 1080.0f);
}

// 控制y
+ (CGFloat)GetControl_Y:(NSInteger)y{
    if (IPhone4s) {
        return y * (IPhone6Plus_SCREEN_HEIGHT / 1920.0f) * (480.0 / 736.0);
    }
    return y * (SCREEN_HEIGHT / 1920.0f);
}

// 控制宽
+ (CGFloat)GetControl_weight:(NSInteger)weight{
    if (IPhone4s) {
        return weight * (IPhone6Plus_SCREEN_WIDTH / 1080.0f) * (320.0 / 414.0);
    }
    return weight * (SCREEN_WIDTH / 1080.0f);
}

// 控制高
+ (CGFloat)GetControl_height:(NSInteger)height{
    if (IPhone4s) {
        return height * (IPhone6Plus_SCREEN_HEIGHT / 1920.0f) * (480.0 / 736.0);
    }
    return height * (SCREEN_HEIGHT / 1920.0f);
}


@end
