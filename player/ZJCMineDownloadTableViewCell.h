//
//  ZJCMineDownloadTableViewCell.h
//  CCRA
//
//  Created by htkg on 16/4/5.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJCMineDownloadModel.h"
@class ZJCMineDownloadTableViewCell;

typedef enum{
    ZJCMineDownloadTableViewCellEditStatusEdit = 1,
    ZJCMineDownloadTableViewCellEditStatusNono
}ZJCMineDownloadTableViewCellEditStatus;

typedef enum {
    ZJCMineDownloadTableViewCellNow = 1,
    ZJCMineDownloadTableViewCellDone,
    ZJCMineDownloadTableViewCellDoneNotWatch
}ZJCMineDownloadTableViewCellType;


typedef void(^editButtonClickedBlock)(UIButton * button,ZJCMineDownloadTableViewCell * cell);


@interface ZJCMineDownloadTableViewCell : UITableViewCell

@property (nonatomic ,assign) ZJCMineDownloadTableViewCellType cellType;
@property (nonatomic ,strong) ZJCMineDownloadModel * model;
@property (nonatomic ,assign) ZJCMineDownloadTableViewCellEditStatus editStatus;
@property (nonatomic ,copy)   editButtonClickedBlock editButtonClickedBlock;

@property (nonatomic ,strong) UIButton * editButton;                        // 编辑按钮
@property (nonatomic ,strong) UIImageView * editImageView;                  // 编辑图片

@property (nonatomic ,strong) UIImageView * thumbnail;                      // 缩略图
@property (nonatomic ,strong) UILabel * titleLabel;                         // 主标题
@property (nonatomic ,strong) UILabel * courseNumber;                       // 下载量 占比
@property (nonatomic ,strong) UILabel * courseSumNumber;                    // 下载量 总
@property (nonatomic ,strong) UILabel * watchStatus;                        // 观看状态

@property (nonatomic ,strong) UIView * progressLabelFront;                  // 下载进度前板
@property (nonatomic ,strong) UIView * progressLabelBack;                   // 下载进度后板

@property (nonatomic ,strong) UILabel * downloadSpeed;                      // 缓存速度

@property (nonatomic ,strong) UIImageView * downStatusImageView;            // 下载状态 图片
@property (nonatomic ,strong) UILabel * downStatusLabel;                    // 下载状态 label

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andEditStatus:(ZJCMineDownloadTableViewCellEditStatus)editStatus;

@end
