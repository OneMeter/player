//
//  ZJCTreeTableView.m
//  CCRA
//
//  Created by htkg on 16/4/1.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCTreeTableView.h"
#import "ZJCTreeModel.h"

// 三种级别的cell都要弄进来
#import "ZJCFirstLevelTableViewCell.h"
#import "ZJCSecondLevelTableViewCell.h"
#import "ZJCThirdLevelTableViewCell.h"




@interface ZJCTreeTableView () <UITableViewDataSource,UITableViewDelegate>

@end



@implementation ZJCTreeTableView

- (instancetype)initWithFrame:(CGRect)frame andData:(NSMutableArray *)data{
    if (self = [super initWithFrame:frame]) {
        self.dataSource = self;
        self.delegate = self;
        _data = data;
        // 重载数据源
        _displayArray = [self reloadSourcesData:data];
    }
    return self;
}


// 重载数据源
- (NSMutableArray *)reloadSourcesData:(NSArray *)data{
    NSMutableArray * tempArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < data.count; i++) {
        ZJCTreeModel * model = [_data objectAtIndex:i];
        if (model.isExpand) {
            [tempArray addObject:model];
        }         
    }
    return tempArray;
}

// 懒加载
- (void)setDisplayArray:(NSMutableArray *)displayArray{
    _displayArray = displayArray;
}

- (void)setData:(NSArray *)data{
    _data = data;
}










#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _displayArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZJCTreeModel * model = [_displayArray objectAtIndex:indexPath.row];
    switch (model.depth) {
        case 0:
        {
            static NSString * NODE_CELL_ID = @"node_cell_first";
            ZJCFirstLevelTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NODE_CELL_ID];
            // cell编辑状态
            ZJCTableViewCellEditStatus cellEditStatus;
            if (self.editStatus == ZJCTableViewEditingStatusEdit) {
                cellEditStatus = ZJCTableViewCellEditStatusEdit;
            }else if(self.editStatus == ZJCTableViewEditingStatusNone){
                cellEditStatus = ZJCTableViewCellEditStatusNone;
            }
            if (cell == nil) {
                cell = [[ZJCFirstLevelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NODE_CELL_ID andEditStatus:cellEditStatus];
                
            }
            // 根据tableview的类型判断cell的类型
            switch (_tableViewType) {
                case ZJCTreeTableViewTypeMyCourse:
                {
                    cell.cellType = ZJCTableViewCellTypeMyCourse;
                }
                    break;
                case ZJCTreeTableViewTypeDownList:
                {
                    cell.cellType = ZJCTableViewCellTypeDownList;
                }
                    break;
                default:
                    break;
            }
            
            // 给cell加载数据
            cell.model = [_displayArray[indexPath.row] data];
            
            // cell编辑删除按钮回调方法
            __weak typeof(self)WeakSelf = self;
            cell.firstEditButtonClickedBlock = ^(UIButton * button,ZJCFirstLevelTableViewCell * cell){
                loginfo(@"一级列表被点击了");
                if (WeakSelf.cellDeleteButtonClicked) {
                    WeakSelf.cellDeleteButtonClicked(self,indexPath);
                }
            };
            
            // cell 缩进方法
            cell.indentationLevel = model.depth;              // 缩进的级别
            cell.indentationWidth = model.indentationWidth;   // 每个缩进级别的距离(只对原生的cell起作用)
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            return cell;
        }
            break;
        case 1:
        {
            static NSString * NODE_CELL_ID = @"node_cell_second";
            ZJCSecondLevelTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NODE_CELL_ID];
            if (cell == nil) {
                cell = [[ZJCSecondLevelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NODE_CELL_ID];
            }
            // 根据tableview的类型判断cell的类型
            switch (_tableViewType) {
                case ZJCTreeTableViewTypeMyCourse:
                {
                    cell.cellType = ZJCTableViewCellTypeMyCourse;
                }
                    break;
                case ZJCTreeTableViewTypeDownList:
                {
                    cell.cellType = ZJCTableViewCellTypeDownList;
                }
                    break;
                default:
                    break;
            }
            
            // 给cell加载数据
            cell.model = [_displayArray[indexPath.row] data];
            
            // "练习题按钮"block
            cell.testButtonClickedBlock = ^(UIButton * button){
                if (self.testButtonClickedBlock) {
                    self.testButtonClickedBlock(button);
                }
            };
            
            // cell 缩进方法
            cell.indentationLevel = model.depth;              // 缩进的级别
            cell.indentationWidth = model.indentationWidth;   // 每个缩进级别的距离(只对原生的cell起作用)
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            return cell;
        }
            break;
        case 2:
        {
            static NSString * NODE_CELL_ID = @"node_cell_third";
            ZJCThirdLevelTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NODE_CELL_ID];
            // cell编辑状态
            ZJCTableViewCellEditStatus cellEditStatus;
            if (self.editStatus == ZJCTableViewEditingStatusEdit) {
                cellEditStatus = ZJCTableViewCellEditStatusEdit;
            }else if(self.editStatus == ZJCTableViewEditingStatusNone){
                cellEditStatus = ZJCTableViewCellEditStatusNone;
            }
            if (cell == nil) {
                cell = [[ZJCThirdLevelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NODE_CELL_ID andEditStatus:cellEditStatus];
            }
            // 根据tableview的类型判断cell的类型
            switch (_tableViewType) {
                case ZJCTreeTableViewTypeMyCourse:
                {
                    cell.cellType = ZJCTableViewCellTypeMyCourse;
                }
                    break;
                case ZJCTreeTableViewTypeDownList:
                {
                    cell.cellType = ZJCTableViewCellTypeDownList;
                }
                    break;
                default:
                    break;
            }
            
            // 给cell加载数据
            cell.model = [_displayArray[indexPath.row] data];
            
            // cell的编辑删除回调方法
            __weak typeof(self)WeakSelf = self;
            cell.thirdEditButtonClickedBlock = ^(UIButton * button,ZJCThirdLevelTableViewCell * cell){
                loginfo(@"三级列表被点击了");
                if (WeakSelf.cellDeleteButtonClicked) {
                    WeakSelf.cellDeleteButtonClicked(self,indexPath);
                }
            };
            
            // cell 缩进方法
            cell.indentationLevel = model.depth;              // 缩进的级别
            cell.indentationWidth = model.indentationWidth;   // 每个缩进级别的距离(只对原生的cell起作用)
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZJCTreeModel * model = _displayArray[indexPath.row];
    switch (model.depth) {
        case 0:
        {
            switch (self.tableViewType) {
                case ZJCTreeTableViewTypeMyCourse:
                {
                    int height = 0;
                    height = [ZJCFrameControl GetControl_Y:240] + 1;
                    return height;
                }
                    break;
                case ZJCTreeTableViewTypeDownList:
                {
                    int height = 0;
                    height = [ZJCFrameControl GetControl_Y:240] + 1;
                    return height;
                }
                    break;    
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (self.tableViewType) {
                case ZJCTreeTableViewTypeMyCourse:
                {
                    int height = 0;
                    height = [ZJCFrameControl GetControl_Y:145] + 1;
                    return height;
                }
                    break;
                case ZJCTreeTableViewTypeDownList:
                {
                    return [ZJCFrameControl GetControl_Y:0];
                }
                    break;    
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch (self.tableViewType) {
                case ZJCTreeTableViewTypeMyCourse:
                {
                    int height = 0;
                    height = [ZJCFrameControl GetControl_Y:185] + 1;
                    return height;
                }
                    break;
                case ZJCTreeTableViewTypeDownList:
                {
                    int height = 0;
                    height = [ZJCFrameControl GetControl_Y:185] + 1;
                    return height;
                }
                    break;    
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    return 100;   // 默认高度
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // 下载列表类型不需要操作
    if (_tableViewType == ZJCTreeTableViewTypeDownList) {
        // 回调Block
        if (self.cellDidSelectedBlock) {
            self.cellDidSelectedBlock((ZJCTreeTableView *)tableView,indexPath);
        }
        return;
    }
    
    // 先修改数据源
    ZJCTreeModel * parentModel = [_displayArray objectAtIndex:indexPath.row];
    
    // 展开关闭操作方法   >>>   其实删除的操作是一样的
    NSUInteger startPosition = indexPath.row + 1;
    NSUInteger endPosition = startPosition;
    BOOL isExpand = NO;      // 默认都是关闭的
    for (int i = 0; i < _data.count; i++) {
        ZJCTreeModel * model = [_data objectAtIndex:i];
        if (model.parentId == parentModel.nodeId) {
            model.isExpand = !model.isExpand;
            if (model.isExpand) {
                [_displayArray insertObject:model atIndex:endPosition];
                isExpand = YES;
                endPosition++;
            }else{
                isExpand = NO;
                endPosition = [self removeAllNodesAtParentNode:parentModel];
                break;
            }
        }
    }
    
    // 获取需要修正的indexPath
    NSMutableArray * indexPathArray = [NSMutableArray array];
    for (NSUInteger i = startPosition; i < endPosition; i++) {
        NSIndexPath * tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPathArray addObject:tempIndexPath];
    }
    
    // 插入或者删除相关节点
    if (isExpand) {
        [self insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }else{
        [self deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }
    
    
    // 回调Block
    if (self.cellDidSelectedBlock) {
        self.cellDidSelectedBlock(self,indexPath);
    }
}



- (NSUInteger)removeAllNodesAtParentNode:(ZJCTreeModel * )parentNode{
    NSUInteger statPositon = [_displayArray indexOfObject:parentNode];
    NSUInteger endPosition = statPositon;
    for (NSUInteger i = statPositon + 1; i < _displayArray.count; i++) {
        ZJCTreeModel * model = [_displayArray objectAtIndex:i];
        endPosition++;
        if (model.depth <= parentNode.depth) {
            break;
        }
        if (endPosition == _displayArray.count - 1) {
            endPosition++;
            model.isExpand = NO;
            break;
        }
        model.isExpand = NO;
    }
    if (endPosition > statPositon) {
        [_displayArray removeObjectsInRange:NSMakeRange(statPositon+1, endPosition-statPositon-1)];
    }
    return endPosition;
}


@end
















