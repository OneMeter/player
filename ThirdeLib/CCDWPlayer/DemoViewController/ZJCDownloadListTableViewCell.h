//
//  ZJCDownloadListTableViewCell.h
//  CCRA
//
//  Created by htkg on 16/5/23.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJCPopDownloadListViewModel.h"

/**
 *  @brief 选中按钮点击回调
 */
typedef void(^SelectedButtonClickedBlock)(UIButton * button);



@interface ZJCDownloadListTableViewCell : UITableViewCell

@property (nonatomic ,copy) SelectedButtonClickedBlock buttonClickedBlock; // 选择按钮点击回调Block

@property (nonatomic ,strong) ZJCPopDownloadListViewModel * model;   // 数据源model

@property (nonatomic ,strong) UILabel * titleLabel;         // 标题
@property (nonatomic ,strong) UILabel * blueVideoLabel;     // 蓝色框框
@property (nonatomic ,strong) UIButton * selectButton;      // 选中按钮
@property (nonatomic ,strong) UILabel * lineView;           // 分割线

@end
