//
//  ZJC_Level0_TableViewCell.m
//  CCRA
//
//  Created by htkg on 16/3/30.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJC_LEVEL0_TableViewCell.h"

@implementation ZJC_LEVEL0_TableViewCell

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
    
    // 主题图片
    self.themeImageView = [[UIImageView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:40], [ZJCFrameControl GetControl_Y:50], [ZJCFrameControl GetControl_weight:237], [ZJCFrameControl GetControl_height:132])];
    self.themeImageView.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:self.themeImageView];
    
    
    // 标题
    self.myTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.themeImageView.frame)+[ZJCFrameControl GetControl_X:30], [ZJCFrameControl GetControl_Y:50], [ZJCFrameControl GetControl_weight:560], [ZJCFrameControl GetControl_height:40])];
    self.myTitleLabel.textColor = ZJCGetColorWith(136, 136, 136, 1);
    self.myTitleLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.myTitleLabel];
    
    
    // 课程数量
    self.courseNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.themeImageView.frame)+[ZJCFrameControl GetControl_X:30], CGRectGetMaxY(self.themeImageView.frame) - [ZJCFrameControl GetControl_Y:30], [ZJCFrameControl GetControl_weight:170], [ZJCFrameControl GetControl_height:30])];
    self.courseNumberLabel.textColor = ZJCGetColorWith(136, 136, 136, 1);
    self.courseNumberLabel.font = [UIFont systemFontOfSize:fontsize];
    [self.contentView addSubview:self.courseNumberLabel];
    
    
    // 下载数量
    self.downNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.courseNumberLabel.frame) + [ZJCFrameControl GetControl_X:13], CGRectGetMinY(self.courseNumberLabel.frame), [ZJCFrameControl GetControl_weight:460], [ZJCFrameControl GetControl_height:30])];
    self.downNumberLabel.textColor = ZJCGetColorWith(136, 136, 136, 1);
    self.downNumberLabel.font = [UIFont systemFontOfSize:fontsize];
    [self.contentView addSubview:self.downNumberLabel];
    
    
    // 详情按钮
    self.arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:1080 - 10 - 88], [ZJCFrameControl GetControl_Y:70], [ZJCFrameControl GetControl_weight:44], [ZJCFrameControl GetControl_height:24])];
    self.arrowImageView.image = [UIImage imageNamed:@"cour_arrow_up"];
    [self.contentView addSubview:self.arrowImageView];
    
    
    // 选择按钮
    self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectButton.frame = CGRectMake( [ZJCFrameControl GetControl_X:1080 - 10 - 88 - 30], 0, [ZJCFrameControl GetControl_weight:88 + 10 + 30], [ZJCFrameControl GetControl_Y:260]);
    self.selectButton.backgroundColor = [UIColor clearColor];
    //    [self.selectButton setImage:[UIImage imageNamed:@"selectbutton_nor"] forState:UIControlStateNormal];
    //    [self.selectButton setImage:[UIImage imageNamed:@"select_select"] forState:UIControlStateSelected];
    [self.selectButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.selectButton];
    
    // 选中图片
    self.selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:30], [ZJCFrameControl GetControl_Y:70+88], [ZJCFrameControl GetControl_weight:44], [ZJCFrameControl GetControl_weight:44])];
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
    NSLog(@"1点击事件");
    button.selected = !button.selected;
    
    // 回调
    if ([self cell0SelectBlock]) {
        self.cell0SelectBlock(self,button);
    }
}





// 分割线
- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, SINGLE_LINE_WIDTH);          //线宽
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetRGBStrokeColor(context, LineColor);             //线的颜色
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, self.bounds.size.height);  //起点坐标
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);   //终点坐标
    CGContextStrokePath(context);
}

@end

