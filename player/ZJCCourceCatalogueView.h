//
//  ZJCCourceCatalogueView.h
//  CCRA
//
//  Created by htkg on 16/3/29.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJCCourceCatalogueModel.h"

///**
// *  @brief 仿照系统的index结构  记录自己的myindex
// */
//typedef struct {
//    NSInteger section;
//    NSInteger row;
//    BOOL isSection;
//}ZJCSelectedIndex;

/**
 *  @brief 练习题按钮点击回调方法
 */
typedef void(^PracticeVCPush) (UIButton *button,NSString * testId,BOOL isDown);

/**
 *  @brief 行、头点击回调方法
 */
typedef void(^CellClicked)(id sender,NSString * videoId,NSString * title,NSString * lessonid,BOOL isSection,NSInteger selectSection,NSInteger selectRow);





@interface ZJCCourceCatalogueView : UIView <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) NSMutableArray * dataSource;               // 数据结构(从上级获取到的数据)

@property (nonatomic ,copy) PracticeVCPush pushPraBlock;                 // 练习题点击回调
@property (nonatomic ,copy) CellClicked cellClicked;                     // "cell"点击回调

@property (nonatomic ,strong) NSIndexPath * selectedIndex;               // 选中 >>> 1.cell 2.section
//@property (nonatomic ,assign) ZJCSelectedIndex mySelectIndex;          // 选中的index

@property (nonatomic ,strong)  UITableView * tableView;           // 展示表格

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)sectionBackViewClicked:(UIButton *)button;

@end
