//
//  ZJC_LEVEL2_TableViewCell.m
//  CCRA
//
//  Created by htkg on 16/3/30.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJC_LEVEL2_TableViewCell.h"

@implementation ZJC_LEVEL2_TableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
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
    CGFloat fontsize = 11;
    
    // 标题
    self.myTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:100], [ZJCFrameControl GetControl_Y:35], [ZJCFrameControl GetControl_weight:560], [ZJCFrameControl GetControl_height:40])];
    self.myTitleLabel.textColor = ZJCGetColorWith(136, 136, 136, 1);
    self.myTitleLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:self.myTitleLabel];
    
    // 时间
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:150], [ZJCFrameControl GetControl_Y:120], [ZJCFrameControl GetControl_weight:560], [ZJCFrameControl GetControl_height:35])];
    self.timeLabel.textColor = ZJCGetColorWith(136, 136, 136, 1);
    self.timeLabel.font = [UIFont systemFontOfSize:fontsize];
    [self.contentView addSubview:self.timeLabel];
    
    // 选择按钮
    self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectButton.frame = CGRectMake([ZJCFrameControl GetControl_X:1080 - 10 - 88 - 30], 0, [ZJCFrameControl GetControl_weight:88 + 10 + 30], [ZJCFrameControl GetControl_Y:186]);
    //    [self.selectButton setImage:[UIImage imageNamed:@"cour_btn_normal"] forState:UIControlStateNormal];
    //    [self.selectButton setImage:[UIImage imageNamed:@"cour_btn_selected"] forState:UIControlStateSelected];
    [self.selectButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.selectButton];
    
    // 选中图片
    self.selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:30], [ZJCFrameControl GetControl_Y:100], [ZJCFrameControl GetControl_weight:44], [ZJCFrameControl GetControl_weight:44])];
    if (_model.isSelected == YES) {
        self.selectImageView.image = [UIImage imageNamed:@"select_select"];
        self.selectButton.selected = YES;
    }else{
        self.selectImageView.image = [UIImage imageNamed:@"selectbutton_nor"];
        self.selectButton.selected = NO;
    }
    [self.selectButton addSubview:self.selectImageView];
}


- (void)selectButtonClicked:(UIButton *)button{
    NSLog(@"3点击事件");
    button.selected = !button.selected;
    
    // 回调
    if ([self cell2SelectBlock]) {
        self.cell2SelectBlock(self,button);
    }
}






- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, SINGLE_LINE_WIDTH);          // 线宽
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetRGBStrokeColor(context, LineColor);             // 线的颜色
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, [ZJCFrameControl GetControl_X:120], self.bounds.size.height);  // 起点坐标
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);           // 终点坐标
    CGContextStrokePath(context);
}

@end


























//    // 分割线
//    UILabel * label = [[UILabel alloc] init];
//    label.backgroundColor = ZJCGetColorWith(230, 230, 230, 1);
//    [self.contentView addSubview:label];
//    __weak UILabel *blockLabel = label;
//    __weak typeof(self) weakSelf = self;
//    [blockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(weakSelf.contentView.mas_left).offset([ZJCFrameControl GetControl_X:120]);
//        make.top.equalTo(weakSelf.contentView.mas_bottom).offset(-3);
//        make.bottom.equalTo(weakSelf.contentView.mas_bottom).offset(-2);
//        make.size.mas_equalTo(CGSizeMake([ZJCFrameControl GetControl_weight:1080], 1));
//    }];