//
//  ZJCThirdLevelTableViewCell.h
//  CCRA
//
//  Created by htkg on 16/4/4.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCTableViewCellBase.h"
#import "ZJCThirdLevelModel.h"
#import "CircleProgressView.h"
@class ZJCThirdLevelTableViewCell;

/**
 编辑按钮 回调
 */
typedef void(^ThirdEditButtonClickedBlock)(UIButton * button,ZJCThirdLevelTableViewCell * cell);


@interface ZJCThirdLevelTableViewCell : ZJCTableViewCellBase

@property (nonatomic ,strong) ZJCThirdLevelModel * model;         // 模型
@property (nonatomic ,copy) ThirdEditButtonClickedBlock thirdEditButtonClickedBlock;

@property (nonatomic ,strong) UIButton * editButton;              // 编辑按钮
@property (nonatomic ,strong) UIImageView * editImageView;        // 编辑图片

@property (nonatomic ,strong) UIView * progressLabelFront;        // 下载进度前板
@property (nonatomic ,strong) UIView * progressLabelBack;         // 下载进度后板

@property (nonatomic ,strong) UIView * downStatusView;            // 下载状态板
@property (nonatomic ,strong) UIImageView * downStatusImageView;  // 下载状态图片
@property (nonatomic ,strong) UILabel * downStatusLabel;          // 下载状态label

@property (nonatomic ,strong) UILabel * downSumNumber;            // 下载总量

@property (nonatomic ,strong) UILabel * myTitleLabel;             // 标题按钮
@property (nonatomic ,strong) UILabel * timeLabel;                // 课程时间
@property (nonatomic ,strong) UILabel * downAllLabel;             // "已缓存"
@property (nonatomic ,strong) UIButton * selectButton;            // 选择按钮

@property (nonatomic ,strong) UILabel * loadSpeedLabel;           // 下载速度

@property (nonatomic ,strong) CircleProgressView * progressView;  // 圆形进度条


/**
 自定义初始化方法
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andEditStatus:(ZJCTableViewCellEditStatus)editStatus;

@end
