//
//  ZJCButtonWithEdgeBottomLine.m
//  CCRA
//
//  Created by htkg on 16/4/15.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCButtonWithEdgeBottomLine.h"

@implementation ZJCButtonWithEdgeBottomLine

- (void)setLineEdgeInsetRight:(CGFloat)lineEdgeInsetRight{
    _lineEdgeInsetRight = lineEdgeInsetRight;
}


- (void)drawRect:(CGRect)rect{
    int height = self.height;
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, SINGLE_LINE_WIDTH);          //线宽
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetRGBStrokeColor(context, LineColor);             //线的颜色
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, height - SINGLE_LINE_ADJUST_OFFSET);  //起点坐标
    CGContextAddLineToPoint(context, _lineEdgeInsetRight, height - SINGLE_LINE_ADJUST_OFFSET);   //终点坐标
    CGContextStrokePath(context);
}





@end
