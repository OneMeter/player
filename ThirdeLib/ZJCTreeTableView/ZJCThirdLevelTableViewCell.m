//
//  ZJCThirdLevelTableViewCell.m
//  CCRA
//
//  Created by htkg on 16/4/4.
//  Copyright © 2016年 htkg. All rights reserved.
//


/*
 －－－下载详情页面 －－具体到某一课程内－－显示每一条视频进度的页面
 */

#import "ZJCThirdLevelTableViewCell.h"

@implementation ZJCThirdLevelTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andEditStatus:(ZJCTableViewCellEditStatus)editStatus {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 编辑状态
        self.editStatus = editStatus;
        
        // 配置自己的东西
        [self configSelf];
    }
    return self;
}


- (void)configSelf{
    // 编辑按钮
    self.editButton = [[UIButton alloc] init];
    [self.contentView addSubview:self.editButton];
    [self.editButton addTarget:self action:@selector(thirdEditButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (self.editStatus == ZJCTableViewCellEditStatusEdit) {
        _editButton.frame = CGRectMake([ZJCFrameControl GetControl_X:0], [ZJCFrameControl GetControl_Y:0], [ZJCFrameControl GetControl_weight:172], [ZJCFrameControl GetControl_height:185]);
    }else if(self.editStatus == ZJCTableViewCellEditStatusNone){
        _editButton.hidden = YES;
    }
    
    self.editImageView = [[UIImageView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:120], [ZJCFrameControl GetControl_Y:185/2 - 60/2], [ZJCFrameControl GetControl_weight:60], [ZJCFrameControl GetControl_weight:60])];
    if (self.editButton.selected == YES) {
        self.editImageView.image = [UIImage imageNamed:@"select_select"];
    }else{
        self.editImageView.image = [UIImage imageNamed:@"select_normal"];
    }
    [self.editButton addSubview:self.editImageView];
    
    
    
    // 标题
    //    WithFrame:CGRectMake([ZJCFrameControl GetControl_X:60], [ZJCFrameControl GetControl_Y:35], [ZJCFrameControl GetControl_weight:560], [ZJCFrameControl GetControl_height:40])
    self.myTitleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.myTitleLabel];
    self.myTitleLabel.textColor = ZJCGetColorWith(56, 56, 56, 1);
    self.myTitleLabel.font = [UIFont systemFontOfSize:13];
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.myTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.editButton.mas_right).offset([ZJCFrameControl GetControl_X:60]);
        make.top.equalTo(weakSelf.editButton).offset([ZJCFrameControl GetControl_Y:35]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1000], [ZJCFrameControl GetControl_height:40]));
    }];
    
    
    // 进度条 －－ 背景灰色
    self.progressLabelBack = [[UIView alloc] init];
    [self.contentView addSubview:self.progressLabelBack];
    self.progressLabelBack.backgroundColor = ZJCGetColorWith(229, 229, 229, 1);
    [weakSelf.progressLabelBack mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.myTitleLabel.mas_left);
        make.top.equalTo(weakSelf.myTitleLabel.mas_bottom).offset([ZJCFrameControl GetControl_Y:20]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:900], [ZJCFrameControl GetControl_height:15]));
    }];
    
    //进度条 －－ 当前进度
    self.progressLabelFront = [[UIView alloc] init];
    [self.contentView addSubview:self.progressLabelFront];
    self.progressLabelFront.backgroundColor = THEME_BACKGROUNDCOLOR;
    [weakSelf.progressLabelFront mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.myTitleLabel.mas_left);
        make.top.equalTo(weakSelf.myTitleLabel.mas_bottom).offset([ZJCFrameControl GetControl_Y:20]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:900], [ZJCFrameControl GetControl_height:15]));
    }];
    
    
    // 下载状态 (底板 + 图片 + 文字板)
    self.downStatusView = [[UIView alloc] init];
    [self.contentView addSubview:self.downStatusView];
    [weakSelf.downStatusView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.myTitleLabel.mas_left);
        make.top.equalTo(weakSelf.myTitleLabel.mas_bottom).offset([ZJCFrameControl GetControl_Y:15+20+10]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:400], [ZJCFrameControl GetControl_height:40]));
    }];
    self.downStatusImageView = [[UIImageView alloc] init];
    [self.downStatusView addSubview:self.downStatusImageView];
    self.downStatusImageView.image = [UIImage imageNamed:@"down_ing"];
    [weakSelf.downStatusImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.downStatusView.mas_left);
        make.top.equalTo(weakSelf.downStatusView.mas_top);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:40], [ZJCFrameControl GetControl_height:40]));
    }];
    self.downStatusLabel = [[UILabel alloc] init];
    [self.downStatusView addSubview:self.downStatusLabel];
    self.downStatusLabel.textColor = THEME_BACKGROUNDCOLOR;
    if (IPhone4s) {
        self.downStatusLabel.font = [UIFont systemFontOfSize:11];
    }else{
        self.downStatusLabel.font = [UIFont systemFontOfSize:12];
    }
    [weakSelf.downStatusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.downStatusView.mas_left).offset([ZJCFrameControl GetControl_X:40]);
        make.top.equalTo(weakSelf.downStatusView.mas_top);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:400-40], [ZJCFrameControl GetControl_height:40]));
    }];
    
    
    // 下载总量文字数量
    self.downSumNumber = [[UILabel alloc] init];
    [self.contentView addSubview:self.downSumNumber];
    self.downSumNumber.textColor = [UIColor grayColor];
    if (IPhone4s) {
        self.downSumNumber.font = [UIFont systemFontOfSize:11];
    }else{
        self.downSumNumber.font = [UIFont systemFontOfSize:12];
    }
    [weakSelf.downSumNumber mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView.mas_right).offset(-[ZJCFrameControl GetControl_X:60 + 45 + 150]);
        make.top.equalTo(weakSelf.downStatusView.mas_top);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:400-40], [ZJCFrameControl GetControl_height:40]));
    }];
    
    
    
    // 时间
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:120], [ZJCFrameControl GetControl_Y:120], [ZJCFrameControl GetControl_weight:145], [ZJCFrameControl GetControl_height:35])];
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.timeLabel];
    
    
    // "已缓存"
    self.downAllLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.timeLabel.frame), [ZJCFrameControl GetControl_Y:120], [ZJCFrameControl GetControl_weight:145], [ZJCFrameControl GetControl_height:35])];
    self.downAllLabel.textColor = THEME_BACKGROUNDCOLOR;
    self.downAllLabel.font = [UIFont systemFontOfSize:12];
    self.downAllLabel.text = @"已缓存";
    [self.contentView addSubview:self.downAllLabel];
    
    
    
    // 选择按钮
    self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectButton.frame = CGRectMake([ZJCFrameControl GetControl_X:1080-10-88],[ZJCFrameControl GetControl_Y:100], [ZJCFrameControl GetControl_weight:44], [ZJCFrameControl GetControl_weight:44]);
    [self.selectButton setImage:[UIImage imageNamed:@"cour_btn_normal"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"cour_btn_selected"] forState:UIControlStateSelected];
    [self.selectButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.selectButton];
    
    
    // 缓冲速度  (1.6M/S) ---下载详情页面的cell
    self.loadSpeedLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.loadSpeedLabel];
    self.loadSpeedLabel.textColor = [UIColor grayColor];
    self.loadSpeedLabel.font = [UIFont systemFontOfSize:10];
    self.loadSpeedLabel.textAlignment = NSTextAlignmentRight;
    self.loadSpeedLabel.hidden = YES;
    //    self.loadSpeedLabel.adjustsFontSizeToFitWidth = YES;
    [weakSelf.loadSpeedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.progressLabelBack.mas_right);
        make.top.equalTo(weakSelf.contentView.mas_bottom).offset(-[ZJCFrameControl GetControl_Y:60]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:460], [ZJCFrameControl GetControl_height:30]));
    }];
    
    
    // 圆形进度条
    _progressView = [[CircleProgressView alloc] init];
    [self.contentView addSubview:_progressView];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.arcBackColor = ZJCGetColorWith(229, 229, 229, 1);
    self.progressView.arcFinishColor = ZJCGetColorWith(95, 151, 228, 1);
    self.progressView.arcUnfinishColor = ZJCGetColorWith(95, 151, 228, 1);
    self.progressView.width = 2;
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView).offset([ZJCFrameControl GetControl_X:975]);
        make.top.equalTo(weakSelf.contentView).offset([ZJCFrameControl GetControl_Y:58]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:63], [ZJCFrameControl GetControl_weight:63]));
    }];
    
    
//    // 分割线
//    UILabel * label = [[UILabel alloc] init];
//    label.backgroundColor = ZJCGetColorWith(230, 230, 230, 1);
//    [self.contentView addSubview:label];
//    __weak UILabel *blockLabel = label;
//    [blockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(weakSelf.contentView.mas_left).offset([ZJCFrameControl GetControl_X:120]);
//        make.top.equalTo(weakSelf.contentView.mas_bottom).offset(-3);
//        make.bottom.equalTo(weakSelf.contentView.mas_bottom).offset(-2);
//        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080], 1));
//    }];
}

// 弃用的选择按钮
- (void)selectButtonClicked:(UIButton *)button{
    
}





// 模型赋值
- (void)setModel:(ZJCThirdLevelModel *)model{
    _model = model;
    
    switch (self.cellType) {
        case ZJCTableViewCellTypeMyCourse:
        {
            _selectButton.hidden = YES;
            _myTitleLabel.text = [NSString stringWithFormat:@"%.2ld %@",(long)[_model.myCountNumber integerValue],_model.title];
            
            NSArray * timePer = [_model.timeNumber componentsSeparatedByString:@":"];
            CGFloat timeSum = [timePer[0] floatValue] * 60 + [timePer[1] floatValue];
            if ([timePer[2] floatValue] >= 30) {
                timeSum += 1;
            }
            _timeLabel.text = [NSString stringWithFormat:@"%.0f分钟",timeSum];
            _progressLabelBack.hidden = YES;
            _progressLabelFront.hidden = YES;
            _downStatusView.hidden = YES;
            _downSumNumber.hidden = YES;
            _loadSpeedLabel.hidden = YES;
            _downAllLabel.hidden = YES;
        }
            break;
        case ZJCTableViewCellTypeDownList:
        {
            _selectButton.hidden = YES;
            _progressView.hidden = YES;
            _downAllLabel.hidden = YES;
            _myTitleLabel.text = _model.name;
            
            if (_model.treeModelStatus == ZJCTreeModelStatusFinish) {
                _loadSpeedLabel.hidden = YES;
                self.downStatusLabel.text = @"已完成";
            }else if (_model.treeModelStatus == ZJCTreeModelStatusWait){
                _loadSpeedLabel.hidden = YES;
                self.downStatusLabel.text = @"等待中";
            }else if (_model.treeModelStatus == ZJCTreeModelStatusPause){
                _loadSpeedLabel.hidden = YES;
                self.downStatusLabel.text = @"已暂停";
            }else if(_model.treeModelStatus == ZJCTreeModelStatusDownloading){
                _loadSpeedLabel.hidden = NO;
                self.downStatusLabel.text = @"下载中";
                if ((_model.speed / 1024.0) > 1024) {
                    _loadSpeedLabel.text = [NSString stringWithFormat:@"%.2fMB/s",_model.speed/1024.0/1024.0];
                }else{
                    _loadSpeedLabel.text = [NSString stringWithFormat:@"%.1fKB/s",_model.speed/1024.0];
                }
            }
            
            
            __weak typeof(self) weakSelf = self;
            [weakSelf.progressLabelFront mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(weakSelf.myTitleLabel.mas_left);
                make.top.equalTo(weakSelf.myTitleLabel.mas_bottom).offset([ZJCFrameControl GetControl_Y:20]);
                make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:900 * [weakSelf.model.isover floatValue]], [ZJCFrameControl GetControl_height:15]));
            }];
            _downSumNumber.hidden = YES;
            
            // 编辑状态
            if (self.editStatus == ZJCTableViewCellEditStatusEdit) {
                if (_model.isSelected == YES) {
                    self.editImageView.image = [UIImage imageNamed:@"select_select"];
                    self.editButton.selected = YES;
                }else{
                    self.editImageView.image = [UIImage imageNamed:@"select_normal"];
                    self.editButton.selected = NO;
                }
            }
        }
            break;    
        default:
            break;
    }
}



// 编辑状态 选择按钮操作
- (void)thirdEditButtonClicked:(UIButton *)button{
    if (self.editButton.selected == YES) {
        self.editImageView.image = [UIImage imageNamed:@"select_normal"];
        self.editButton.selected = NO;
        if (self.thirdEditButtonClickedBlock) {
            self.thirdEditButtonClickedBlock(button,self);
        }
        
    }else if(self.editButton.selected == NO){
        self.editImageView.image = [UIImage imageNamed:@"select_select"];
        self.editButton.selected = YES;
        if (self.thirdEditButtonClickedBlock) {
            self.thirdEditButtonClickedBlock(button,self);
        }
    }
}




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
