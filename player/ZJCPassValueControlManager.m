//
//  ZJCPassValueControl.m
//  CCRA
//
//  Created by htkg on 16/4/26.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCPassValueControlManager.h"

@implementation ZJCPassValueControlManager

+ (ZJCPassValueControlManager *)defaultManager{
    static ZJCPassValueControlManager * manager = nil;  
    static dispatch_once_t predicate;  
    dispatch_once(&predicate, ^{  
        manager = [[self alloc] init];   
    });  
    return manager;  
}



- (void)setIsSection:(BOOL)isSection{
    _isSection = isSection;
}

- (void)setSelectSection:(NSInteger)selectSection{
    _selectSection = selectSection;
}

- (void)setSelectRow:(NSInteger)selectRow{
    _selectRow = selectRow;
}


@end
