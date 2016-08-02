//
//  ZJCDownloadListTableViewCell.m
//  CCRA
//
//  Created by htkg on 16/5/23.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCDownloadListTableViewCell.h"

@implementation ZJCDownloadListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 配置
        [self configSelf];
    }
    return self;
}


// 配置自己本身
- (void)configSelf{
    // 蓝色视频框框
    self.blueVideoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height / 4, 40, self.height / 2)];
    self.blueVideoLabel.text = @"视频";
    self.blueVideoLabel.textAlignment = NSTextAlignmentCenter;
    self.blueVideoLabel.textColor = [UIColor whiteColor];
    self.blueVideoLabel.font = [UIFont systemFontOfSize:12];
    self.blueVideoLabel.backgroundColor = [UIColor blueColor];
    self.blueVideoLabel.layer.masksToBounds = YES;
    self.blueVideoLabel.layer.cornerRadius = 3;
    [self.contentView addSubview:self.blueVideoLabel];
    
    // 标题
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.blueVideoLabel.frame) + 10, 0, self.width - self.height - self.blueVideoLabel.width - 10, self.height)];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.titleLabel];
    
    
    // 选中按钮
    self.selectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - self.height, 0, self.height, self.height)];
    [self.selectButton setImage:[UIImage imageNamed:@"select_normal"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"select_select"] forState:UIControlStateSelected];
    [self.contentView addSubview:self.selectButton];
    [self.selectButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // 分割线
    _lineView = [[UILabel alloc] init];
    _lineView.backgroundColor = ZJCGetColorWith(230, 230, 230, 1);
    [self.contentView addSubview:_lineView];
    __weak typeof(self)weakSelf = self;
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView.mas_left).offset(0);
        make.top.equalTo(weakSelf.contentView.mas_bottom).offset(-3);
        make.bottom.equalTo(weakSelf.contentView.mas_bottom).offset(-2);
        make.size.mas_equalTo(CGSizeMake(weakSelf.bounds.size.width, 1));
    }];
}



// 对应模型
- (void)setModel:(ZJCPopDownloadListViewModel *)model{
    _model = model;
    
    // 区分当前的是section还是row
    if (_model.cellType == ZJCDownloadListTableViewCellTypeSection) {
        // 标题
        self.titleLabel.text = _model.name;
        // 蓝色提示框
        self.blueVideoLabel.hidden = YES;
        self.blueVideoLabel.frame = CGRectMake(0, 0, 0, 0);
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.blueVideoLabel.frame), 0, self.width - self.height - self.blueVideoLabel.width, self.height);
    }else if(_model.cellType == ZJCDownloadListTableViewCellTypeRow){
        // 标题
        self.titleLabel.text = _model.name;
        // 蓝色提示框
        self.blueVideoLabel.hidden = NO;
        self.blueVideoLabel.frame = CGRectMake(0, self.height / 4, 40, self.height / 2);
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.blueVideoLabel.frame) + 10, 0, self.width - self.height - self.blueVideoLabel.width - 10, self.height);
    }
    
    // 分割线是否隐藏
    if (_model.isHaveSepereter == YES) {
        _lineView.hidden = NO;
    }else{
        _lineView.hidden = YES;
    }
    
    // 选中按钮
    if (_model.isHaveSelectButton == YES) {
        self.selectButton.hidden = NO;
        if (_model.isselected == YES) {
            self.selectButton.selected = YES;
        }else{
            self.selectButton.selected = NO;
        }
    }else{
        self.selectButton.hidden = YES;
    }
}





/**
 *  @brief 选中按钮回调问题
 */
- (void)selectButtonClicked:(UIButton *)button{
    if (self.buttonClickedBlock) {
        self.buttonClickedBlock(button);
    }
}







@end
