//
//  ZJCDownListModel.h
//  CCRA
//
//  Created by htkg on 16/3/30.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJCDownListModel : NSObject

@property (nonatomic ,assign) NSInteger nodeLevel;   // 处在的层级
@property (nonatomic ,assign) NSInteger type;        // 节点类型
@property (nonatomic ,assign) NSInteger orderNumber; // ***序号   >>>   (这个只有三级列表需要用到)
@property (nonatomic ,strong) id nodeData;           // 节点数据
@property (nonatomic ,assign) BOOL isExpanded;       // 节点是否展开
@property (nonatomic ,assign) BOOL isSelected;       // 节点是否选中

@property (nonatomic ,strong) NSMutableArray * sonNodes;  // 子节点

@end
