//
//  ZJCCourceCatalogueSmallModel.m
//  CCRA
//
//  Created by htkg on 16/4/11.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCCourceCatalogueSmallModel.h"

@implementation ZJCCourceCatalogueSmallModel
@synthesize id;

// 防止多余属性出错的方法
+ (BOOL)propertyIsOptional:(NSString *)propertyName{
    return YES;
}

@end
