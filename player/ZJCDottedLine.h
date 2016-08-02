//
//  ZJCDottedLine.h
//  CCRA
//
//  Created by htkg on 16/4/27.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJCDottedLine : NSObject

+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;

@end
