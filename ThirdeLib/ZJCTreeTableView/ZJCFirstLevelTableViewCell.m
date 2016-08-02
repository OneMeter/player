//
//  ZJCFirstLevelTableViewCell.m
//  CCRA
//
//  Created by htkg on 16/4/4.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCFirstLevelTableViewCell.h"



@interface ZJCFirstLevelTableViewCell ()

@end



@implementation ZJCFirstLevelTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andEditStatus:(ZJCTableViewCellEditStatus)editStatus{
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
    [self.editButton addTarget:self action:@selector(firstEditButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (self.editStatus == ZJCTableViewCellEditStatusEdit) {
        _editButton.frame = CGRectMake([ZJCFrameControl GetControl_X:0], [ZJCFrameControl GetControl_Y:0], [ZJCFrameControl GetControl_weight:142], [ZJCFrameControl GetControl_height:240]);
    }else if(self.editStatus == ZJCTableViewCellEditStatusNone){
        _editButton.hidden = YES;
    }
    
    self.editImageView = [[UIImageView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:60], [ZJCFrameControl GetControl_Y:240/2 - 60/2], [ZJCFrameControl GetControl_weight:60], [ZJCFrameControl GetControl_weight:60])];
    if (self.editButton.selected == YES) {
        self.editImageView.image = [UIImage imageNamed:@"select_select"];
    }else{
        self.editImageView.image = [UIImage imageNamed:@"select_normal"];
    }
    [self.editButton addSubview:self.editImageView];
    
    
    // 主题图片
    self.themeImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.themeImageView];
    __weak __typeof(self) weakSelf = self; 
    [weakSelf.themeImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.editButton.mas_right).offset([ZJCFrameControl GetControl_X:40]);
        make.top.equalTo(weakSelf.editButton.mas_top).offset([ZJCFrameControl GetControl_Y:60]);
        make.bottom.equalTo(weakSelf.editButton.mas_bottom).offset(-[ZJCFrameControl GetControl_Y:50]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:237], [ZJCFrameControl GetControl_height:132]));
    }];
    
    
    // 下载状态 图片 (在主题图片上面显示的)
    self.downStatusImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.downStatusImageView];
    [self.downStatusImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.editButton.mas_right).offset([ZJCFrameControl GetControl_X:40 + 50]);
        make.centerY.equalTo(weakSelf.themeImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:40], [ZJCFrameControl GetControl_weight:40]));
    }];
    
    // 下载状态 文字 (在主题图片上面显示的)
    self.downStatusLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.downStatusLabel];
    [self.downStatusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.editButton.mas_right).offset([ZJCFrameControl GetControl_X:40 + 50 + 40]);
        make.centerY.equalTo(weakSelf.themeImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:150], [ZJCFrameControl GetControl_weight:40]));
    }];
    self.downStatusLabel.font = [UIFont systemFontOfSize:12];
    self.downStatusLabel.textColor = [UIColor whiteColor];
    
    
    
    // 标题
    self.myTitleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.myTitleLabel];
    self.myTitleLabel.textColor = ZJCGetColorWith(50, 50, 50, 1);
    self.myTitleLabel.font = [UIFont systemFontOfSize:14];
    [weakSelf.myTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.themeImageView.mas_right).offset([ZJCFrameControl GetControl_X:30]);
        make.top.equalTo(weakSelf.contentView).offset([ZJCFrameControl GetControl_Y:50]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:560], [ZJCFrameControl GetControl_height:40]));
    }];
    
    
    // 进度条
    self.progressLabelBack = [[UIView alloc] init];
    [self.contentView addSubview:self.progressLabelBack];
    self.progressLabelBack.backgroundColor = ZJCGetColorWith(229, 229, 229, 1);
    [weakSelf.progressLabelBack mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.themeImageView.mas_right).offset([ZJCFrameControl GetControl_X:30]);
        make.top.equalTo(weakSelf.myTitleLabel.mas_bottom).offset([ZJCFrameControl GetControl_Y:30]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:600 + 50], [ZJCFrameControl GetControl_height:15]));
    }];
    
    self.progressLabelFront = [[UIView alloc] init];
    [self.contentView addSubview:self.progressLabelFront];
    self.progressLabelFront.backgroundColor = THEME_BACKGROUNDCOLOR;
    [weakSelf.progressLabelFront mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.themeImageView.mas_right).offset([ZJCFrameControl GetControl_X:30]);
        make.top.equalTo(weakSelf.myTitleLabel.mas_bottom).offset([ZJCFrameControl GetControl_Y:30]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:600 + 50], [ZJCFrameControl GetControl_height:15]));
    }];
    
    
    
    
    // 课程数量
    self.courseNumberLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.courseNumberLabel];
    self.courseNumberLabel.textColor = [UIColor grayColor];
    self.courseNumberLabel.font = [UIFont systemFontOfSize:10];
    [weakSelf.courseNumberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.themeImageView.mas_right).offset([ZJCFrameControl GetControl_X:30]);
        make.top.equalTo(weakSelf.themeImageView.mas_bottom).offset(-[ZJCFrameControl GetControl_Y:30]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:150], [ZJCFrameControl GetControl_height:30]));
    }];
    
    
    // 下载数量
    self.downNumberLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.downNumberLabel];
    self.downNumberLabel.textColor = [UIColor grayColor];
    self.downNumberLabel.font = [UIFont systemFontOfSize:10];
    [weakSelf.downNumberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.courseNumberLabel.mas_right).offset([ZJCFrameControl GetControl_X:13]);
        make.top.equalTo(weakSelf.themeImageView.mas_bottom).offset(-[ZJCFrameControl GetControl_Y:30]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:300], [ZJCFrameControl GetControl_height:30]));
    }];
    
    
    // 下载速度
    self.loadSpeedLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.loadSpeedLabel];
    self.loadSpeedLabel.textColor = [UIColor grayColor];
    self.loadSpeedLabel.font = [UIFont systemFontOfSize:10];
    self.loadSpeedLabel.textAlignment = NSTextAlignmentRight;
    self.loadSpeedLabel.hidden = YES;
    [weakSelf.loadSpeedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView.mas_right).offset(-[ZJCFrameControl GetControl_X:500]);
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
        make.left.equalTo(weakSelf.contentView).offset([ZJCFrameControl GetControl_X:912-14]);
        make.top.equalTo(weakSelf.contentView).offset([ZJCFrameControl GetControl_Y:91-14]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:90], [ZJCFrameControl GetControl_weight:90]));
    }];
    
    
    // 详情按钮
    self.arrowImageView = [[UIImageView alloc] init];
    self.arrowImageView.image = [UIImage imageNamed:@"cour_arrow"];
    [self.contentView addSubview:self.arrowImageView];
    [self.arrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView).offset([ZJCFrameControl GetControl_X:1080-10-88]);
        make.top.equalTo(weakSelf.contentView).offset([ZJCFrameControl GetControl_Y:70]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:44], [ZJCFrameControl GetControl_height:24]));
    }];
    
    
    // 选择按钮 (弃用)
    self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.selectButton];
    [self.selectButton setImage:[UIImage imageNamed:@"cour_btn_normal"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"cour_btn_selected"] forState:UIControlStateSelected];
    [self.selectButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.arrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView).offset([ZJCFrameControl GetControl_X:1080-10-88]);
        make.top.equalTo(weakSelf.contentView).offset([ZJCFrameControl GetControl_Y:70 + 88]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:44], [ZJCFrameControl GetControl_height:24]));
    }];
    
    
    
//    // 分割线
//    UILabel * label = [[UILabel alloc] init];
//    label.backgroundColor = ZJCGetColorWith(230, 230, 230, 1);
//    [self.contentView addSubview:label];
//    __weak UILabel *blockLabel = label;
//    [blockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(weakSelf.contentView.mas_left).offset(0);
//        make.top.equalTo(weakSelf.contentView.mas_bottom).offset(-3);
//        make.bottom.equalTo(weakSelf.contentView.mas_bottom).offset(-2);
//        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080], 1));
//    }];
}


// 弃用的选择按钮
- (void)selectButtonClicked:(UIButton *)button{
    
}



// 赋值的操作,这里可以根据cell的类型  对不同的cell进行区分
- (void)setModel:(ZJCFirstLevelModel *)model{
    _model = model;
    
    if (self.cellType == ZJCTableViewCellTypeMyCourse) {           // "我的课程"
        _selectButton.hidden = YES;
        _arrowImageView.frame = CGRectMake([ZJCFrameControl GetControl_X:1080-20-44], [ZJCFrameControl GetControl_Y:110], [ZJCFrameControl GetControl_weight:44], [ZJCFrameControl GetControl_height:24]);
        _downNumberLabel.textColor = THEME_BACKGROUNDCOLOR;
        _myTitleLabel.text = _model.title;
        _courseNumberLabel.text = [NSString stringWithFormat:@"%@节课",_model.courseNumber];
        _downNumberLabel.text = [NSString stringWithFormat:@"已学习(%@/%@)",_model.downNumber,_model.courseNumber];
        [_themeImageView sd_setImageWithURL:[NSURL URLWithString:_model.headImgPath] placeholderImage:[UIImage imageNamed:@"banner"]];
        _progressLabelBack.hidden = YES;
        _progressLabelFront.hidden = YES;
        _loadSpeedLabel.hidden = YES;
        // 进度条
        _progressView.hidden = NO;
        _progressView.percent = [_model.isover floatValue] / 100.0;
        
    }else if (self.cellType == ZJCTableViewCellTypeDownList){      // "缓存下载详细列表"
        _selectButton.hidden = YES;
        _arrowImageView.hidden = YES;
        if ([_model.maxcount integerValue] == 0) {
            _courseNumberLabel.text = @"1节课";
        }else{
            _courseNumberLabel.text = [NSString stringWithFormat:@"%@节课",_model.maxcount];
        }
        
        
        // 下载状态
        if (_model.treeModelStatus == ZJCTreeModelStatusFinish) {
            _loadSpeedLabel.hidden = YES;
            _downStatusImageView.image = [UIImage imageNamed:@"download_status"];
            _downStatusLabel.text = @"已完成";
        }else if (_model.treeModelStatus == ZJCTreeModelStatusWait){
            _loadSpeedLabel.hidden = YES;
            _downStatusImageView.image = [UIImage imageNamed:@"wait_status"];
            _downStatusLabel.text = @"等待中";
        }else if (_model.treeModelStatus == ZJCTreeModelStatusPause){
            _loadSpeedLabel.hidden = YES;
            _downStatusImageView.image = [UIImage imageNamed:@"pause_status"];
            _downStatusLabel.text = @"已暂停";
        }else if(_model.treeModelStatus == ZJCTreeModelStatusDownloading){
            _loadSpeedLabel.hidden = NO;
            _downStatusImageView.image = [UIImage imageNamed:@"download_status"];
            _downStatusLabel.text = @"下载中";
            if ((_model.speed / 1024.0) > 1024) {
                _loadSpeedLabel.text = [NSString stringWithFormat:@"%.2fMB/s",_model.speed/1024.0/1024.0];
            }else{
                _loadSpeedLabel.text = [NSString stringWithFormat:@"%.1fKB/s",_model.speed/1024.0];
            }
        }else if (_model.treeModelStatus == ZJCTreeModelStatusError){  // 借代没有子节点的情况
            _loadSpeedLabel.hidden = YES;
            _downStatusImageView.image = [UIImage imageNamed:@""];
            _downStatusLabel.text = @"";
        }
        
        
        __weak typeof(self) weakSelf = self;
        [weakSelf.courseNumberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.themeImageView.mas_right).offset([ZJCFrameControl GetControl_X:30]);
            make.top.equalTo(weakSelf.themeImageView.mas_bottom).offset(-[ZJCFrameControl GetControl_Y:30]);
            make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:100], [ZJCFrameControl GetControl_height:30]));
        }];
        
        // 判断是否显示进度条的旧代码
        if ([_model.maxcount boolValue] != 0) {
            [weakSelf.progressLabelBack mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(weakSelf.themeImageView.mas_right).offset([ZJCFrameControl GetControl_X:30]);
                make.top.equalTo(weakSelf.myTitleLabel.mas_bottom).offset([ZJCFrameControl GetControl_Y:30]);
                make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:0], [ZJCFrameControl GetControl_height:15]));
            }];
            
            [weakSelf.progressLabelFront mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(weakSelf.themeImageView.mas_right).offset([ZJCFrameControl GetControl_X:30]);
                make.top.equalTo(weakSelf.myTitleLabel.mas_bottom).offset([ZJCFrameControl GetControl_Y:30]);
                make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:0], [ZJCFrameControl GetControl_height:15]));
            }];
        }else{
            [weakSelf.progressLabelFront mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(weakSelf.themeImageView.mas_right).offset([ZJCFrameControl GetControl_X:30]);
                make.top.equalTo(weakSelf.myTitleLabel.mas_bottom).offset([ZJCFrameControl GetControl_Y:30]);
                make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:(600 + 50)*[weakSelf.model.isover floatValue]], [ZJCFrameControl GetControl_height:15]));
            }];
        }
        
        
        _downNumberLabel.hidden = YES;
        _progressView.hidden = YES;
        _myTitleLabel.text = model.name;
        _downNumberLabel.text = model.downNumber;
        [_themeImageView sd_setImageWithURL:[NSURL URLWithString:_model.imageurl] placeholderImage:[UIImage imageNamed:@"banner"]];
        
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
}





/**
 编辑状态  选择按钮点击事件
 */
- (void)firstEditButtonClicked:(UIButton *)button{
    if (self.editButton.selected == YES) {
        self.editImageView.image = [UIImage imageNamed:@"select_normal"];
        self.editButton.selected = NO;
        if (self.firstEditButtonClickedBlock) {
            self.firstEditButtonClickedBlock(button,self);
        }
        
    }else if(self.editButton.selected == NO){
        self.editImageView.image = [UIImage imageNamed:@"select_select"];
        self.editButton.selected = YES;
        if (self.firstEditButtonClickedBlock) {
            self.firstEditButtonClickedBlock(button,self);
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












//if ([_model.isover isEqualToString:@"1"]) {
//    _loadSpeedLabel.hidden = YES;
//}else if ([_model.isover isEqualToString:@"0"] || _model.isover == nil || [_model.isover isEqualToString:@""]){
//    _loadSpeedLabel.hidden = YES;
//}else{
//    _loadSpeedLabel.hidden = NO;
//    if ((model.speed / 1024.0) > 1024) {
//        _loadSpeedLabel.text = [NSString stringWithFormat:@"%.2fMB/s",_model.speed/1024.0/1024.0];
//    }else{
//        _loadSpeedLabel.text = [NSString stringWithFormat:@"%.1fKB/s",_model.speed/1024.0];
//    }
//}