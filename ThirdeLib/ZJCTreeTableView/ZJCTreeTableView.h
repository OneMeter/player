//
//  ZJCTreeTableView.h
//  CCRA
//
//  Created by htkg on 16/4/1.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZJCTreeModel;
@class ZJCTreeTableView;

/**
 cell点击回调block
 */
typedef void(^cellDidSelected)(ZJCTreeTableView * tableview,NSIndexPath * indexPath);


/**
 cell编辑删除按钮回调事件
 */
typedef void(^cellDeleteButtonClicked)(UITableView * table,NSIndexPath * indexPath);


/**
 "练习题按钮"block   >>>   专门为"练习题"按钮写的block
 */
typedef void(^testButtonBlock)(UIButton * button);

/**
 编辑状态   >>>   (可选)
 */
typedef enum {
    ZJCTableViewEditingStatusEdit = 1,
    ZJCTableViewEditingStatusNone
}ZJCTableViewEditingStatus;

/**
 表格类型   >>>  (可选)
 */
typedef enum {
    ZJCTreeTableViewTypeMyCourse = 1,
    ZJCTreeTableViewTypeDownList
}ZJCTreeTableViewType;





@interface ZJCTreeTableView : UITableView

/**
 cell点击回调Block
 */
@property (nonatomic ,copy) cellDidSelected cellDidSelectedBlock;

/**
 编辑删除按钮点击回调
 */
@property (nonatomic ,copy) cellDeleteButtonClicked cellDeleteButtonClicked;

/**
 "练习题"按钮block
 */
@property (nonatomic ,copy) testButtonBlock testButtonClickedBlock;

/**
 表格类型   >>>  (可选)
 */
@property (nonatomic ,assign) ZJCTreeTableViewType tableViewType;

/**
 编辑状态   >>>  (可选)
 */
@property (nonatomic ,assign)  ZJCTableViewEditingStatus editStatus;

/**
 外界数据   >>>   请求到的总数据(需要经过加壳处理)
 */
@property (nonatomic ,strong) NSArray * data;         

/**
 数据源   >>>   加载tableview的数据
 */
@property (nonatomic ,strong) NSMutableArray * displayArray;  


// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame andData:(NSMutableArray *)data;
// 重载数据源的方法
- (NSMutableArray *)reloadSourcesData:(NSArray *)data;


@end
