//
//  ZJC_LEVEL1_TableViewCell.h
//  CCRA
//
//  Created by htkg on 16/3/30.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJCDownListModel.h"
@class ZJC_LEVEL1_TableViewCell;


/**
 *  @brief 选择按钮点击回调
 */
typedef void(^cell1SelectedButtonClicked)(ZJC_LEVEL1_TableViewCell * cell ,UIButton * button);



@interface ZJC_LEVEL1_TableViewCell : UITableViewCell

@property (nonatomic ,strong) ZJCDownListModel * model;
@property (nonatomic ,strong) UILabel * myTitleLabel;
@property (nonatomic ,strong) UIButton * selectButton;          // 选择按钮
@property (nonatomic ,strong) UIImageView * selectImageView;    // 选择按钮图片

@property (nonatomic ,copy) cell1SelectedButtonClicked cell1SelectBlock;  // 选中按钮点击回调Block

@end
