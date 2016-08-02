//
//  ZJCPassValueControl.h
//  CCRA
//
//  Created by htkg on 16/4/26.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJCPassValueControlManager : NSObject

@property (nonatomic ,assign) BOOL isSection;
@property (nonatomic ,assign) NSInteger selectSection;
@property (nonatomic ,assign) NSInteger selectRow;

+ (ZJCPassValueControlManager *)defaultManager;

@end
