//
//  ZJCSecondLevelTableViewCell.m
//  CCRA
//
//  Created by htkg on 16/4/4.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCSecondLevelTableViewCell.h"

@implementation ZJCSecondLevelTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 配置自己的东西
        [self configSelf];
    }
    return self;
}


- (void)configSelf{
    // 标题
    self.myTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:60], [ZJCFrameControl GetControl_Y:53], [ZJCFrameControl GetControl_weight:1080-60], [ZJCFrameControl GetControl_height:40])];
    self.myTitleLabel.textColor = ZJCGetColorWith(106, 106, 106, 1);
    self.myTitleLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.myTitleLabel];
    
    // 选择按钮
    self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectButton.frame = CGRectMake([ZJCFrameControl GetControl_X:1080-10-88],[ZJCFrameControl GetControl_Y:17], [ZJCFrameControl GetControl_weight:44], [ZJCFrameControl GetControl_weight:44]);
    [self.selectButton setImage:[UIImage imageNamed:@"cour_btn_normal"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"cour_btn_selected"] forState:UIControlStateSelected];
    [self.selectButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.selectButton];
    
    
    // 圆形进度条
    _progressView = [[CircleProgressView alloc] init];
    [self.contentView addSubview:_progressView];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.arcBackColor = ZJCGetColorWith(229, 229, 229, 1);
    self.progressView.arcFinishColor = ZJCGetColorWith(95, 151, 228, 1);
    self.progressView.arcUnfinishColor = ZJCGetColorWith(95, 151, 228, 1);
    self.progressView.width = 2;
    
    __weak __typeof(self) weakSelf = self; 
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView).offset([ZJCFrameControl GetControl_X:975]);
        make.top.equalTo(weakSelf.contentView).offset([ZJCFrameControl GetControl_Y:41]);
        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:63], [ZJCFrameControl GetControl_weight:63]));
    }];
    
    // 练习题按钮
    _testButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _testButton.frame = CGRectMake([ZJCFrameControl GetControl_X:753], [ZJCFrameControl GetControl_Y:66], [ZJCFrameControl GetControl_weight:180], [ZJCFrameControl GetControl_height:65]);
    [_testButton setTitle:@"练习题" forState:UIControlStateNormal];
    if (IPhone4s) {
        _testButton.titleLabel.font = [UIFont systemFontOfSize:9];
    }else {
        _testButton.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    [_testButton setTitleColor:THEME_BACKGROUNDCOLOR forState:UIControlStateNormal];
    UIImage * image = [[UIImage imageNamed:@"down_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_testButton setImage:image forState:UIControlStateNormal];
    logdebug(@"Button.frame %f%f",_testButton.width,_testButton.height);
    
    _testButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _testButton.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 38);
    _testButton.titleEdgeInsets = UIEdgeInsetsMake(-1, -30, 2, -5);
    [_testButton addTarget:self action:@selector(testButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_testButton];
    
    
//    // 分割线
//    UILabel * label = [[UILabel alloc] init];
//    label.backgroundColor = ZJCGetColorWith(230, 230, 230, 1);
//    [self.contentView addSubview:label];
//    __weak UILabel *blockLabel = label;
//    [blockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(weakSelf.contentView.mas_left).offset([ZJCFrameControl GetControl_X:60]);
//        make.top.equalTo(weakSelf.contentView.mas_bottom).offset(-3);
//        make.bottom.equalTo(weakSelf.contentView.mas_bottom).offset(-2);
//        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080], 1));
//    }];
}

// 弃用的选择按钮
- (void)selectButtonClicked:(UIButton *)button{
    
}

// 练习题按钮
- (void)testButtonClicked:(UIButton *)button{
    if (self.testButtonClickedBlock) {
        self.testButtonClickedBlock(button);
    }
}


// 模型赋值
- (void)setModel:(ZJCSecondLevelModel *)model{
    _model = model;
    
    if (self.cellType == ZJCTableViewCellTypeMyCourse) {
        _selectButton.hidden = YES;
        //        _myTitleLabel.frame = CGRectMake([ZJCFrameControl GetControl_X:60], [ZJCFrameControl GetControl_Y:66], [ZJCFrameControl GetControl_weight:1080-60], [ZJCFrameControl GetControl_height:40]);
        _myTitleLabel.text = _model.title;
        // 圆形进度条
        _progressView.hidden = NO;
        _progressView.percent = [_model.isover floatValue] / 100.0;
        
        // 练习题按钮
        if ([_model.eid isEqualToString:@"0"]) {
            _testButton.hidden = YES;
        }else{
            _testButton.hidden = NO;
        }
        
    }else if (self.cellType == ZJCTableViewCellTypeDownList){
        self.hidden = YES;
    }
}



//
//- (void)drawRect:(CGRect)rect{
//    [super drawRect:rect];
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetLineCap(context, kCGLineCapRound);
//    CGContextSetLineWidth(context, SINGLE_LINE_WIDTH);          //线宽
//    CGContextSetAllowsAntialiasing(context, true);
//    CGContextSetRGBStrokeColor(context, LineColor);             //线的颜色
//    CGContextBeginPath(context);
//    CGContextMoveToPoint(context, 0, self.bounds.size.height - SINGLE_LINE_ADJUST_OFFSET);  //起点坐标
//    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height - SINGLE_LINE_ADJUST_OFFSET);   //终点坐标
//    CGContextStrokePath(context);
//}

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












