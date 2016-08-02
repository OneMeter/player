//
//  ZJCCourceCatelogueTableViewCell.m
//  CCRA
//
//  Created by htkg on 16/3/29.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCCourceCatelogueTableViewCell.h"
#import "CircleProgressView.h"



@interface ZJCCourceCatelogueTableViewCell ()

@property (nonatomic ,strong) UIView * sectionBackView;           // 头视图底板
@property (nonatomic ,strong) UILabel * titleLabel;               // 课程名称     
@property (nonatomic ,strong) UILabel * timeLabel;                // 课程时间   
@property (nonatomic ,strong) UILabel * statusLabel;              // 缓冲状态
@property (nonatomic ,strong) UIButton * testButton;              // 练习题按钮
@property (nonatomic ,strong) CircleProgressView * progressView;  // 圆形进度条

@end




@implementation ZJCCourceCatelogueTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 配置自己的参数
        [self configSelf];
        
    }
    return self;
}



- (void)configSelf{
    CGFloat fontsize = 11;
    // 底板
    _sectionBackView = [[UIView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:0], [ZJCFrameControl GetControl_Y:0], [ZJCFrameControl GetControl_weight:1080], [ZJCFrameControl GetControl_height:206])];
    [self.contentView addSubview:_sectionBackView];
    
    // 标题
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:40], [ZJCFrameControl GetControl_Y:40], [ZJCFrameControl GetControl_weight:700], [ZJCFrameControl GetControl_height:45])];
    _titleLabel.textColor = ZJCGetColorWith(102, 102, 102, 1);
    //    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.font = [UIFont systemFontOfSize:13];
    [_sectionBackView addSubview:_titleLabel];
    
    // 时长
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:100], [ZJCFrameControl GetControl_Y:40+45+30], [ZJCFrameControl GetControl_weight:130], [ZJCFrameControl GetControl_height:40])];
    _timeLabel.textColor = ZJCGetColorWith(168, 168, 168, 1);
    //    _timeLabel.adjustsFontSizeToFitWidth = YES;
    _timeLabel.font = [UIFont systemFontOfSize:fontsize];
    [_sectionBackView addSubview:_timeLabel];
    
    // 缓存状态状态
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:100+110+80], [ZJCFrameControl GetControl_Y:40+45+30], [ZJCFrameControl GetControl_weight:150], [ZJCFrameControl GetControl_height:40])];
    _statusLabel.textColor = THEME_BACKGROUNDCOLOR;
    _statusLabel.font = [UIFont systemFontOfSize:fontsize];
    [_sectionBackView addSubview:_statusLabel];
    
    
    // 圆形进度条
    _progressView = [[CircleProgressView alloc] init];
    [self.sectionBackView addSubview:_progressView];
    _progressView.backgroundColor = [UIColor clearColor];
    _progressView.arcBackColor = ZJCGetColorWith(229, 229, 229, 1);
    _progressView.arcFinishColor = ZJCGetColorWith(95, 151, 228, 1);
    _progressView.arcUnfinishColor = ZJCGetColorWith(95, 151, 228, 1);
    _progressView.width = 1;
    __weak typeof(self) weakSelf = self;
    [weakSelf.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.sectionBackView.mas_centerY);
        make.right.equalTo(weakSelf.sectionBackView.mas_right).offset(-[ZJCFrameControl GetControl_Y:78]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:90], [ZJCFrameControl GetControl_weight:90]));
    }];
}


// 给赋值
- (void)setModel:(ZJCCourceCatalogueSmallModel *)model{
    _model = model;
    
    _titleLabel.text = [NSString stringWithFormat:@"%.2ld %@",_cellIndexpath.row + 1,model.name];
    
    // 课程时间
    NSString * timeHor = [model.videoduration componentsSeparatedByString:@":"][0];
    NSString * timeMin = [model.videoduration componentsSeparatedByString:@":"][1];
    _timeLabel.text = [NSString stringWithFormat:@"%d分钟",[timeMin intValue] + [timeHor intValue]*60];
    
    // 练习题按钮
    if (_model.eid == nil || [_model.eid isEqualToString:@""]) {
        _testButton.hidden = YES;
    }else{
        _testButton.hidden = NO;
    }
    
    // 圆形进度条
    if (_model.studybar == nil || [_model.studybar isEqualToString:@""]) {
        _progressView.hidden = YES;
    }else{
        _progressView.percent = [model.studybar integerValue]/100.0;
    }
    
    // 是否已经缓存了
    ZJCFMDBManager * manager = [ZJCFMDBManager defaultManager];
    NSArray * array = [manager selectRecordWithMyid:_model.id];
    if (array.count != 0) {
        if ([array[0][@"isover"] isEqualToString:@"1"]) {
            _statusLabel.hidden = NO;
            _statusLabel.text = @"已缓存";
        }else{
            _statusLabel.hidden = YES;
        }
    }else{
        _statusLabel.hidden = YES;
    }
}




- (void)setCellIndexpath:(NSIndexPath *)cellIndexpath{
    _cellIndexpath = cellIndexpath;
}


// 画线
- (void)setEdgeLineSize:(CGFloat)edgeLineSize{
    _edgeLineSize = edgeLineSize;
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






