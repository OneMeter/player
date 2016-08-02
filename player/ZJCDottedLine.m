//
//  ZJCDottedLine.m
//  CCRA
//
//  Created by htkg on 16/4/27.
//  Copyright © 2016年 htkg. All rights reserved.
//


/**
 ** lineView:	   需要绘制成虚线的view
 ** lineLength:	   虚线的宽度
 ** lineSpacing:   虚线的间距
 ** lineColor:	   虚线的颜色
 **/


#import "ZJCDottedLine.h"

@implementation ZJCDottedLine

+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    // 设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    // 设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    // 设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    // 设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(lineView.frame), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    // 把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}

@end
