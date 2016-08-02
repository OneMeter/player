//
//  ZJCTreeModel.m
//  CCRA
//
//  Created by htkg on 16/4/1.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCTreeModel.h"


@implementation ZJCTreeModel

// 加载数据
- (instancetype)initWithParentId:(NSInteger)parentId andNodeId:(NSInteger)nodeId andDepth:(NSInteger)depth andExpand:(BOOL)expand andData:(id)data{
    if (self = [super init]) {
        self.parentId = parentId;
        self.nodeId = nodeId;
        self.depth = depth;
        self.indentationWidth = 100;
        self.isExpand = expand;
        self.data = data;
    }
    return self;
}


// 特殊处理  >>>  有时候会直接从后台接到数据.考虑到一些特殊的数据格式,比方说java的null,在这里处理  
- (void)setParentId:(NSInteger)parentId{
    _parentId = parentId;
}

- (void)setNodeId:(NSInteger)nodeId{
    _nodeId = nodeId;
}

- (void)setDepth:(NSInteger)depth{
    _depth = depth;
}

- (void)setIsExpand:(BOOL)isExpand{
    _isExpand = isExpand;
}

- (void)setData:(id)data{
    _data = data;
}




@end
