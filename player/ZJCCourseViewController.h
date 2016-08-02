//
//  ZJCCourseIntroductionViewController.h
//  CCRA
//
//  Created by htkg on 16/3/29.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCBaseViewController.h"

/**
 *  @brief 获取了数据的回调
 */
typedef void(^GetDataAlready)(BOOL isGet);


@interface ZJCCourseViewController : ZJCBaseViewController

@property (nonatomic ,copy) GetDataAlready alreadyGetData;            // 获取到数据回调

@property (nonatomic ,strong) NSDictionary * receiveDataSource;       // 收到的数据
@property (nonatomic ,strong) NSMutableArray * nextDataSource;        // 传到下一个界面的数据

@property (nonatomic ,copy) NSString * courseID;   // 课程id
@property (nonatomic ,copy) NSString * codeID;     // codeid
@property (nonatomic ,copy) NSString * userName;   // 用户名
@property (nonatomic ,copy) NSString * middelname; // 课程 名称

@property (nonatomic,strong) UIImageView * finishPratiace;//完成练习

@property (nonatomic ,assign) NSInteger currentPlayerDuration;

/**
 *  @brief 播放按钮点击事件
 */
- (void)playerButtonClicked:(UIButton *)button;

/**
 *  @brief 专用播放接口
 */
- (void)playNewVedioWithVideoId:(NSString *)videoid andLessonid:(NSString *)lessonid andTitle:(NSString *)title andDepth:(NSInteger)depth andSectionId:(NSString *)sectionId;
- (void)playNewVedioWithLocalPath:(NSString *)localPath andLessonid:(NSString *)lessonid andTitle:(NSString *)title andDepth:(NSInteger)depth andSectionId:(NSString *)sectionId;


@end

