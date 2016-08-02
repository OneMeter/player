//
//  ZJC_Level0_TableViewCell.h
//  CCRA
//
//  Created by htkg on 16/3/30.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJCDownListModel.h"
@class ZJC_LEVEL0_TableViewCell;


/**
 *  @brief 选择按钮点击回调
 */
typedef void(^cell0SelectedButtonClicked)(ZJC_LEVEL0_TableViewCell * cell ,UIButton * button);




@interface ZJC_LEVEL0_TableViewCell : UITableViewCell

@property (nonatomic ,strong) ZJCDownListModel * model;

@property (nonatomic ,strong) UIImageView * themeImageView;     // 主图片

@property (nonatomic ,strong) UILabel * myTitleLabel;           // 主标题
@property (nonatomic ,strong) UILabel * downNumberLabel;        // 下载课程数
@property (nonatomic ,strong) UILabel * courseNumberLabel;      // 课程数量

@property (nonatomic ,strong) UIImageView * arrowImageView;     // 详情按钮    
@property (nonatomic ,strong) UIButton * selectButton;          // 选择按钮
@property (nonatomic ,strong) UIImageView * selectImageView;    // 选择按钮图片

@property (nonatomic ,copy) cell0SelectedButtonClicked cell0SelectBlock;  // 选中按钮点击回调Block

@end
