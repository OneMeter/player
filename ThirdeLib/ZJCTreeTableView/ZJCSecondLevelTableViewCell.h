//
//  ZJCSecondLevelTableViewCell.h
//  CCRA
//
//  Created by htkg on 16/4/4.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCTableViewCellBase.h"
#import "ZJCSecondLevelModel.h"
#import "CircleProgressView.h"

/**
 练习题按钮回调
 */
typedef void(^TestButtonClickedBlock)(UIButton * button);


@interface ZJCSecondLevelTableViewCell : ZJCTableViewCellBase

@property (nonatomic ,copy) TestButtonClickedBlock testButtonClickedBlock;

@property (nonatomic ,strong) ZJCSecondLevelModel * model;        // 数据模型
@property (nonatomic ,strong) UILabel * myTitleLabel;             // 标题
@property (nonatomic ,strong) UIButton * selectButton;            // 选择按钮
@property (nonatomic ,strong) CircleProgressView * progressView;  // 圆形进度条
@property (nonatomic ,strong) UIButton * testButton;              // 练习题按钮

@end
