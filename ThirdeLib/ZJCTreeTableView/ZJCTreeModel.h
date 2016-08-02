//
//  ZJCTreeModel.h
//  CCRA
//
//  Created by htkg on 16/4/1.
//  Copyright © 2016年 htkg. All rights reserved.
//
/**
 *  @author XiaoChuan, 16-04-01 16:04:08
 *  
 *  树形列表  专用数据模型
 */


#import <Foundation/Foundation.h>

@interface ZJCTreeModel : NSObject

@property (nonatomic ,assign) BOOL isSelected;          // 编辑删除使用的标志量

@property (nonatomic ,assign) NSInteger parentId;       // 父节点 id  >>> 根节点的id为-1
@property (nonatomic ,assign) NSInteger nodeId;         // 本节点 id
@property (nonatomic ,assign) NSInteger depth;          // 本节点 层级  c.g:缩进界别
@property (nonatomic ,assign) CGFloat indentationWidth; //                缩进宽度
@property (nonatomic ,assign) BOOL isExpand;            // 本节点 展开状态

@property (nonatomic ,strong) id data;                  // 本节点的数据  >>> 用来装载其他类型的模型的


/**
 *  @author XiaoChuan, 16-04-01 16:04:48
 *  
 *  加载"数据"的接口   >>> 加载数据可以是模型,可以是字典,可以是数组(视具体情况自定制)
 */
- (instancetype)initWithParentId:(NSInteger)parentId andNodeId:(NSInteger)nodeId andDepth:(NSInteger)depth andExpand:(BOOL)expand andData:(id)data;


@end
