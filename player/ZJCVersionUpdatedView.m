//
//  ZJCVersionUpdatedView.m
//  CCRA
//
//  Created by htkg on 16/5/13.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCVersionUpdatedView.h"
#import "POP.h"

@interface ZJCVersionUpdatedView () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) NSString * verisionNumber;            // 需要传入  版本号
@property (nonatomic ,strong) NSDictionary * verisionInfor;         // 需要传入  更新内容

@property (nonatomic ,strong) UIView * myAlertBackView;             // 弹出框的底板
@property (nonatomic ,strong) UILabel * myNewVersionNumber;         // 新版本 版本号提示
@property (nonatomic ,strong) UILabel * mySeparateLine;             // 分割线
@property (nonatomic ,strong) UILabel * myNewVersionContentTitle;   // 新版本 内容提示
@property (nonatomic ,strong) UITableView * myNewVersionContent;   // 新版本 内容   >>>   可变内容,自动计算高度
@property (nonatomic ,strong) UIButton * notUpdateButton;           // "暂不更新"
@property (nonatomic ,strong) UIButton * updateButton;              // "立即更新"

@end


@implementation ZJCVersionUpdatedView

- (instancetype)initWithFrame:(CGRect)frame withVerisionNumber:(NSString *)versionNumber andVersionInfor:(NSDictionary *)versionInfor{
    if (self = [super initWithFrame:frame]) {
        // 初始化参数
        _verisionNumber = versionNumber;
        _verisionInfor = [NSDictionary dictionaryWithDictionary:versionInfor];
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        // 配置
        [self configSelf];
    }
    return self;
}

// 配置
- (void)configSelf{
    // 弹出菜单背板
    _myAlertBackView = [[UIView alloc] initWithFrame:CGRectMake(self.center.x - [ZJCFrameControl GetControl_weight:863]/2 , -[ZJCFrameControl GetControl_height:690], [ZJCFrameControl GetControl_weight:863], [ZJCFrameControl GetControl_height:690])];
    _myAlertBackView.backgroundColor = [UIColor whiteColor];
    _myAlertBackView.layer.masksToBounds = YES;
    _myAlertBackView.layer.cornerRadius = 5;
    [self addSubview:_myAlertBackView];
    
    
    // 版本号  (更新版本:5.1.2)
    _myNewVersionNumber = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:70], [ZJCFrameControl GetControl_Y:55], _myAlertBackView.width - [ZJCFrameControl GetControl_X:70 * 2], [ZJCFrameControl GetControl_height:60])];
    _myNewVersionNumber.textColor = THEME_BACKGROUNDCOLOR;
    _myNewVersionNumber.font = [UIFont systemFontOfSize:16];
    _myNewVersionNumber.textAlignment = NSTextAlignmentLeft;
    _myNewVersionNumber.text = [NSString stringWithFormat:@"更新版本:%@",_verisionInfor[@"versionname"]];
    
    [_myAlertBackView addSubview:_myNewVersionNumber];
    
    
    // 分割线
    _mySeparateLine = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:70], CGRectGetMaxY(_myNewVersionNumber.frame) + [ZJCFrameControl GetControl_Y:25], _myAlertBackView.width - [ZJCFrameControl GetControl_X:70 * 2], 1)];
    _mySeparateLine.backgroundColor = ZJCGetColorWith(191, 191, 191, 1);
    [_myAlertBackView addSubview:_mySeparateLine];
    
    
    // 版本内容提示  (更新内容:)
    _myNewVersionContentTitle = [[UILabel alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:70], CGRectGetMaxY(_myNewVersionNumber.frame) + [ZJCFrameControl GetControl_Y:50], _myAlertBackView.width - [ZJCFrameControl GetControl_X:70 * 2], [ZJCFrameControl GetControl_height:60])];
    _myNewVersionContentTitle.textColor = ZJCGetColorWith(110, 110, 110, 1);
    _myNewVersionContentTitle.font = [UIFont systemFontOfSize:16];
    _myNewVersionContentTitle.text = [NSString stringWithFormat:@"更新内容:"];
    _myNewVersionContentTitle.textAlignment = NSTextAlignmentLeft;
    [_myAlertBackView addSubview:_myNewVersionContentTitle];
    
    
    // 版本内容  (1.XXXX  2.XXXX  ...)
    _myNewVersionContent = [[UITableView alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:70], CGRectGetMaxY(_myNewVersionContentTitle.frame) + [ZJCFrameControl GetControl_Y:25], _myAlertBackView.width - [ZJCFrameControl GetControl_X:70 * 2], [ZJCFrameControl GetControl_Y:260])];
    _myNewVersionContent.delegate = self;
    _myNewVersionContent.dataSource = self;
    _myNewVersionContent.showsHorizontalScrollIndicator = NO;
    _myNewVersionContent.showsVerticalScrollIndicator = NO;
    _myNewVersionContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_myNewVersionContent registerClass:[UITableViewCell class] forCellReuseIdentifier:@"aCell"];
    [_myAlertBackView addSubview:_myNewVersionContent];
    
    
    // "暂不更新"
    _notUpdateButton = [[UIButton alloc] initWithFrame:CGRectMake([ZJCFrameControl GetControl_X:70], CGRectGetMaxY(_myNewVersionContent.frame) + [ZJCFrameControl GetControl_Y:25], [ZJCFrameControl GetControl_weight:280], [ZJCFrameControl GetControl_height:100])];
    [_notUpdateButton setTitle:@"暂不更新" forState:UIControlStateNormal];
    [_notUpdateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_notUpdateButton setBackgroundColor:ZJCGetColorWith(199, 199, 199, 1)];
    _notUpdateButton.layer.masksToBounds = YES;
    _notUpdateButton.cornerRadius = 10;
    _notUpdateButton.borderWidth = 0;
    _notUpdateButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_notUpdateButton addTarget:self action:@selector(notUpdateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_myAlertBackView addSubview:_notUpdateButton];
    
    
    // "立即更新"
    _updateButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_notUpdateButton.frame) + [ZJCFrameControl GetControl_weight:150], CGRectGetMinY(_notUpdateButton.frame), CGRectGetWidth(_notUpdateButton.frame), CGRectGetHeight(_notUpdateButton.frame))];
    [_updateButton setTitle:@"立即更新" forState:UIControlStateNormal];
    [_updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_updateButton setBackgroundColor:THEME_BACKGROUNDCOLOR];
    _updateButton.layer.masksToBounds = YES;
    _updateButton.cornerRadius = 10;
    _updateButton.borderWidth = 0;
    _updateButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_updateButton addTarget:self action:@selector(updateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_myAlertBackView addSubview:_updateButton];
}











#pragma mark - 更新按钮回调方法
- (void)notUpdateButtonClicked:(UIButton *)button{
    if (self.notUpdateBlock) {
        self.notUpdateBlock(button);
    }
}


- (void)updateButtonClicked:(UIButton *)button{
    if (self.updateBlock) {
        self.updateBlock(button);
    }
}











#pragma mark 弹出动画 + 退出动画
- (void)showAlert{
    // 加载到window上去
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    // 加载Pop动画,配置动画当前属性
    POPSpringAnimation * showAlertAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    showAlertAnimation.fromValue = @(-[ZJCFrameControl GetControl_height:690]);
    showAlertAnimation.toValue = @(self.center.y);
    showAlertAnimation.velocity = @(1000);
    showAlertAnimation.springBounciness = 20;
    
    // 弹出来当前的弹窗
    [_myAlertBackView.layer pop_addAnimation:showAlertAnimation forKey:@"showAlertAnimation"];
}


- (void)dismissAlert{
    // 或者动画弹出效果
    // 加载Pop动画,配置动画当前属性
    POPSpringAnimation * dismissAlertAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    dismissAlertAnimation.fromValue = @(self.center.y);
    dismissAlertAnimation.toValue = @(1000);
    dismissAlertAnimation.velocity = @(1000);
    dismissAlertAnimation.springBounciness = 20;
    
    // 弹出来当前的弹窗
    [_myAlertBackView.layer pop_addAnimation:dismissAlertAnimation forKey:@"dismissAlertAnimation"];
    
    // 延后执行
    __block typeof(self) blockSelf = self; 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [blockSelf removeFromSuperview];
    });
}








#pragma mark - 表格视图代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ZJCFrameControl GetControl_height:260]/3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"aCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"aCell"];
    }
    // 配置cell的文字就可以了
    cell.textLabel.text = @"1.修改Bug";
    cell.textLabel.textColor = ZJCGetColorWith(110, 110, 110, 1);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



@end
