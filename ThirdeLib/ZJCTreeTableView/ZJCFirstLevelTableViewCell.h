//
//  ZJCFirstLevelTableViewCell.h
//  CCRA
//
//  Created by htkg on 16/4/4.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCTableViewCellBase.h"
#import "ZJCFirstLevelModel.h"
#import "CircleProgressView.h"
@class ZJCFirstLevelTableViewCell;

typedef void(^FirstEditButtonClickedBlock)(UIButton * button, ZJCFirstLevelTableViewCell * cell);


@interface ZJCFirstLevelTableViewCell : ZJCTableViewCellBase

@property (nonatomic ,strong) ZJCFirstLevelModel * model;
@property (nonatomic ,copy) FirstEditButtonClickedBlock firstEditButtonClickedBlock;


@property (nonatomic ,strong) UIButton * editButton;                       // 编辑按钮
@property (nonatomic ,strong) UIImageView * editImageView;                 // 编辑图片

@property (nonatomic ,strong) UIImageView * themeImageView;                // 主图片
@property (nonatomic ,strong) UILabel * myTitleLabel;                      // 主标题

@property (nonatomic ,strong) UIView * progressLabelFront;                 // 下载进度条 前板
@property (nonatomic ,strong) UIView * progressLabelBack;                  // 下载进度条 后板

@property (nonatomic ,strong) UILabel * downNumberLabel;                   // 下载课程数
@property (nonatomic ,strong) UILabel * courseNumberLabel;                 // 课程数量
@property (nonatomic ,strong) CircleProgressView * progressView;           // 圆形进度条

@property (nonatomic ,strong) UILabel * loadSpeedLabel;                    // 下载速度

@property (nonatomic ,strong) UIImageView * arrowImageView;                // 详情按钮    
@property (nonatomic ,strong) UIButton * selectButton;                     // 选择按钮

@property (nonatomic ,strong) UIImageView * downStatusImageView;           // 下载状态 图片
@property (nonatomic ,strong) UILabel * downStatusLabel;                   // 下载状态 label

/**
 自定义初始化方法
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andEditStatus:(ZJCTableViewCellEditStatus)editStatus;

@end
