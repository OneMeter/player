//
//  ZJCMineDownloadTableViewCell.m
//  CCRA
//
//  Created by htkg on 16/4/5.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCMineDownloadTableViewCell.h"


@interface ZJCMineDownloadTableViewCell ()


@end

/*
 缓存列表的 cell 定制类
 */

@implementation ZJCMineDownloadTableViewCell

// 初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andEditStatus:(ZJCMineDownloadTableViewCellEditStatus)editStatus{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 编辑状态
        self.editStatus = editStatus;
        
        // 配置子视图
        [self configSubviews];
    }
    return self;
}


-(void)configSubviews{
    // 编辑按钮
    self.editButton = [[UIButton alloc] init];
    [self.contentView addSubview:self.editButton];
    [self.editButton addTarget:self action:@selector(editButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (self.editStatus == ZJCMineDownloadTableViewCellEditStatusEdit) {
        _editButton.frame = CGRectMake([ZJCFrameControl GetControl_X:0], [ZJCFrameControl GetControl_Y:0], [ZJCFrameControl GetControl_weight:142], [ZJCFrameControl GetControl_height:256]);
    }else if(self.editStatus == ZJCMineDownloadTableViewCellEditStatusNono){
        _editButton.hidden = YES;
    }
    
    self.editImageView = [[UIImageView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:0], [ZJCFrameControl GetControl_Y:0], [ZJCFrameControl GetControl_weight:60], [ZJCFrameControl GetControl_weight:60])];
    self.editImageView.center = self.editButton.center;
    if (self.editButton.selected == YES) {
        self.editImageView.image = [UIImage imageNamed:@"select_select"];
    }else{
        self.editImageView.image = [UIImage imageNamed:@"select_normal"];
    }
    [self.editButton addSubview:self.editImageView];
    
    
    
    // 缩略图
    self.thumbnail = [[UIImageView alloc] init];
    [self.contentView addSubview:self.thumbnail];
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.thumbnail mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.editButton.mas_right).offset([ZJCFrameControl GetControl_X:30]);
        make.top.equalTo(weakSelf.editButton).offset([ZJCFrameControl GetControl_Y:44]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:325], [ZJCFrameControl GetControl_height:181]));
    }];
    
    
    // 下载状态 图片 (在主题图片上面显示的)
    self.downStatusImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.downStatusImageView];
    [self.downStatusImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.editButton.mas_right).offset([ZJCFrameControl GetControl_X:40 + 50]);
        make.centerY.equalTo(weakSelf.thumbnail.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:40], [ZJCFrameControl GetControl_weight:40]));
    }];
    
    
    // 下载状态 文字 (在主题图片上面显示的)
    self.downStatusLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.downStatusLabel];
    [self.downStatusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.editButton.mas_right).offset([ZJCFrameControl GetControl_X:40 + 50 + 40]);
        make.centerY.equalTo(weakSelf.thumbnail.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:150], [ZJCFrameControl GetControl_weight:40]));
    }];
    self.downStatusLabel.font = [UIFont systemFontOfSize:12];
    self.downStatusLabel.textColor = [UIColor whiteColor];
    
    
    // 总标题
    self.titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.textColor = [UIColor blackColor];
    //    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[ZJCFrameControl GetControl_height:40]];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [weakSelf.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.thumbnail.mas_right).offset([ZJCFrameControl GetControl_X:30]);
        make.top.equalTo(weakSelf.contentView).offset([ZJCFrameControl GetControl_Y:42]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:460 + 100], [ZJCFrameControl GetControl_height:40]));
    }];
    
    // 观看状态点
    self.watchStatus = [[UILabel alloc] init];
    [self.contentView addSubview:self.watchStatus];
    self.watchStatus.backgroundColor = [UIColor redColor];
    
    [weakSelf.watchStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.titleLabel.mas_right).offset([ZJCFrameControl GetControl_X:10]);
        make.top.equalTo(weakSelf.contentView).offset([ZJCFrameControl GetControl_Y:52]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:20], [ZJCFrameControl GetControl_weight:20]));
    }];
    self.watchStatus.layer.masksToBounds = YES;
    self.watchStatus.layer.borderWidth = 0.1;
    self.watchStatus.layer.cornerRadius = [ZJCFrameControl GetControl_weight:20/2];
    
    
    
    // 进度条
    self.progressLabelBack = [[UIView alloc] init];
    [self.contentView addSubview:self.progressLabelBack];
    self.progressLabelBack.backgroundColor = ZJCGetColorWith(229, 229, 229, 1);
    [weakSelf.progressLabelBack mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.thumbnail.mas_right).offset([ZJCFrameControl GetControl_X:30]);
        make.top.equalTo(weakSelf.titleLabel.mas_bottom).offset([ZJCFrameControl GetControl_Y:68]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:400 + 100 + 100], [ZJCFrameControl GetControl_height:20]));
    }];
    
    self.progressLabelFront = [[UIView alloc] init];
    [self.contentView addSubview:self.progressLabelFront];
    self.progressLabelFront.backgroundColor = THEME_BACKGROUNDCOLOR;
    [weakSelf.progressLabelFront mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.thumbnail.mas_right).offset([ZJCFrameControl GetControl_X:30]);
        make.top.equalTo(weakSelf.titleLabel.mas_bottom).offset([ZJCFrameControl GetControl_Y:68]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:400 + 100 + 100], [ZJCFrameControl GetControl_height:20]));
    }];
    
    
    
    
    // 下载占比 (60M/200M)
    self.courseNumber = [[UILabel alloc] init];
    [self.contentView addSubview:self.courseNumber];
    self.courseNumber.textColor = [UIColor grayColor];
    //    self.courseNumber.adjustsFontSizeToFitWidth = YES;
    self.courseNumber.font = [UIFont systemFontOfSize:[ZJCFrameControl GetControl_height:30]];
    self.courseNumber.textAlignment = NSTextAlignmentLeft;
    
    [weakSelf.courseNumber mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.thumbnail.mas_right).offset([ZJCFrameControl GetControl_X:30]);
        make.top.equalTo(weakSelf.progressLabelBack.mas_bottom).offset([ZJCFrameControl GetControl_Y:12]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:180], [ZJCFrameControl GetControl_height:40]));
    }];
    
    
    // 总下载量 (500G)
    self.courseSumNumber = [[UILabel alloc] init];
    [self.contentView addSubview:self.courseSumNumber];
    self.courseSumNumber.textColor = [UIColor grayColor];
    //    self.courseSumNumber.adjustsFontSizeToFitWidth = YES;
    self.courseSumNumber.font = [UIFont systemFontOfSize:[ZJCFrameControl GetControl_height:30]];
    self.courseSumNumber.textAlignment = NSTextAlignmentLeft;
    
    [weakSelf.courseSumNumber mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.courseNumber.mas_right).offset([ZJCFrameControl GetControl_X:0]);
        make.top.equalTo(weakSelf.progressLabelBack.mas_bottom).offset([ZJCFrameControl GetControl_Y:12]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:180], [ZJCFrameControl GetControl_height:40]));
    }];
    
    
    // 缓冲速度 (1.6M/S)
    self.downloadSpeed = [[UILabel alloc] init];
    [self.contentView addSubview:self.downloadSpeed];
    self.downloadSpeed.textColor = THEME_BACKGROUNDCOLOR;
    //    self.downloadSpeed.adjustsFontSizeToFitWidth = YES;
    self.downloadSpeed.font = [UIFont systemFontOfSize:[ZJCFrameControl GetControl_height:30]];
    self.downloadSpeed.textAlignment = NSTextAlignmentLeft;
    
    [weakSelf.downloadSpeed mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView.mas_right).offset(-[ZJCFrameControl GetControl_X:180+30]);
        make.top.equalTo(weakSelf.progressLabelBack.mas_bottom).offset([ZJCFrameControl GetControl_Y:20]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:180], [ZJCFrameControl GetControl_height:40]));
    }];
    
    //    // 分割线
    //    UILabel * label = [[UILabel alloc] init];
    //    label.backgroundColor = ZJCGetColorWith(230, 230, 230, 1);
    //    [self.contentView addSubview:label];
    //    __weak UILabel *blockLabel = label;
    //    [blockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.equalTo(weakSelf.contentView.mas_left).offset([ZJCFrameControl GetControl_X:0]);
    //        make.top.equalTo(weakSelf.contentView.mas_bottom).offset(-3);
    //        make.bottom.equalTo(weakSelf.contentView.mas_bottom).offset(-2);
    //        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080], 1));
    //    }];
}



- (void)setModel:(ZJCMineDownloadModel *)model{
    _model = model;
    
    if (_model.isSelected == YES) {
        self.editImageView.image = [UIImage imageNamed:@"select_select"];
        self.editButton.selected = YES;
    }else if (_model.isSelected == NO){
        self.editImageView.image = [UIImage imageNamed:@"select_normal"];
        self.editButton.selected = NO;
    }
    
    // 缩略图
        [self.thumbnail sd_setImageWithURL:[NSURL URLWithString:_model.imageurl] placeholderImage:[UIImage imageNamed:@"banner"]];
//    self.thumbnail.backgroundColor = [UIColor blueColor];
    
    // 总标题
    self.titleLabel.text = _model.name;
    
    // 下载完成量 // 下载占比
    self.courseNumber.text = [NSString stringWithFormat:@"%@节课",_model.maxcount];
    
    
    // 观看状态点
    _watchStatus.hidden = YES;
    
    
    // 缓冲进度条
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.progressLabelFront mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.thumbnail.mas_right).offset([ZJCFrameControl GetControl_X:30]);
        make.top.equalTo(weakSelf.titleLabel.mas_bottom).offset([ZJCFrameControl GetControl_Y:68]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:(400 + 100 + 100)*[weakSelf.model.isover floatValue]], [ZJCFrameControl GetControl_height:20]));
    }];
    
    // 判断当前模型的下载状态  关掉吧 蓝色的框太难看了
//    switch (_model.isDownloading) {
//        case ZJCMineDownloadModelStstusWait:             // 等待中
//        {
//            self.downloadSpeed.hidden = YES;
//            self.downStatusImageView.image = [UIImage imageNamed:@"wait_status"];
//            self.downStatusLabel.text = @"等待中";
//        }
//            break;
//        case ZJCMineDownloadModelStstusDownloading:      // 下载中
//        {
//            // 缓冲速度
//            if (_model.speed/1024.0 > 1024) {
//                self.downloadSpeed.text = [NSString stringWithFormat:@"%.2fMB/s",(long)_model.speed / 1024.0 / 1024.0];
//            }else{
//                self.downloadSpeed.text = [NSString stringWithFormat:@"%.1fKB/s",(long)_model.speed / 1024.0];
//            }
//            self.downloadSpeed.hidden = NO;
//            // 下载状态
//            self.downStatusImageView.image = [UIImage imageNamed:@"download_status"];
//            self.downStatusLabel.text = @"下载中";
//        }
//            break;
//        case ZJCMineDownloadModelStstusPause:            // 已暂停
//        {
//            // 缓冲速度
//            if (_model.speed/1024.0 > 1024) {
//                self.downloadSpeed.text = [NSString stringWithFormat:@"%.2fMB/s",(long)_model.speed / 1024.0 / 1024.0];
//            }else{
//                self.downloadSpeed.text = [NSString stringWithFormat:@"%.1fKB/s",(long)_model.speed / 1024.0];
//            }
//            self.downloadSpeed.hidden = YES;
//            // 下载状态
//            self.downStatusImageView.image = [UIImage imageNamed:@"download_status"];
//            self.downStatusLabel.text = @"已暂停";
//        }
//            break;
//        case ZJCMineDownloadModelStstusFinish:             // 已完成
//        {
//            self.downloadSpeed.hidden = YES;
//            self.downStatusImageView.image = [UIImage imageNamed:@"download_status"];
//            self.downStatusLabel.text = @"已完成";
//        }
//            break;
//        default:
//            break;
//    }
}



- (void)editButtonClicked:(UIButton *)button{
    if (self.editButton.selected == YES) {
        self.editImageView.image = [UIImage imageNamed:@"select_normal"];
        self.editButton.selected = NO;
        if (self.editButtonClickedBlock) {
            self.editButtonClickedBlock(button,self);
        }
        
    }else if(self.editButton.selected == NO){
        self.editImageView.image = [UIImage imageNamed:@"select_select"];
        self.editButton.selected = YES;
        if (self.editButtonClickedBlock) {
            self.editButtonClickedBlock(button,self);
        }
        
    }
}









#pragma mark - 分割线
- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, SINGLE_LINE_WIDTH);          //线宽
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetRGBStrokeColor(context, LineColor);             //线的颜色
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, self.bounds.size.height - SINGLE_LINE_ADJUST_OFFSET);  //起点坐标
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height - SINGLE_LINE_ADJUST_OFFSET);   //终点坐标
    CGContextStrokePath(context);
}


@end