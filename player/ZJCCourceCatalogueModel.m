//
//  ZJCCourceCatalogueModel.m
//  CCRA
//
//  Created by htkg on 16/3/29.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCCourceCatalogueModel.h"


@implementation ZJCCourceCatalogueModel
@synthesize id;
// 属性多余处理方法
+ (BOOL)propertyIsOptional:(NSString *)propertyName{
    return YES;
}

@end
