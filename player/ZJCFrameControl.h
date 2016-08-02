//
//  ZJCFrameControl.h
//  CCRA
//
//  Created by htkg on 16/2/25.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJCFrameControl : NSObject

// 返回x
+ (CGFloat)GetControl_X:(NSInteger)x;

// 返回y
+ (CGFloat)GetControl_Y:(NSInteger)y;

//返回宽度
+ (CGFloat)GetControl_weight:(NSInteger)weight;

//返回高度
+ (CGFloat)GetControl_height:(NSInteger)height;

@end
