//
//  ZJCViewWithBottonLine.m
//  CCRA
//
//  Created by htkg on 16/4/17.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCViewWithBottonLine.h"

@implementation ZJCViewWithBottonLine

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    int height = self.height;
    // 画分割线
    CGContextSetLineWidth(context, SINGLE_LINE_WIDTH);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetRGBStrokeColor(context, LineColor);  //线的颜色
    CGContextMoveToPoint(context, 0 , height - SINGLE_LINE_ADJUST_OFFSET);
    CGContextAddLineToPoint(context,SCREEN_WIDTH , height - SINGLE_LINE_ADJUST_OFFSET);
    CGContextStrokePath(context);
}



@end
