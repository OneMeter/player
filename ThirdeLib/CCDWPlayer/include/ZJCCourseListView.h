//
//  ZJCCourseLIstView.h
//  CCRA
//
//  Created by htkg on 16/4/12.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 *  @brief cell点击回调事件
 */
typedef void(^courCellSelected)(id sender,NSString * videoId,NSString * title,NSString * lessonid,BOOL isSection,NSInteger selectSeciton,NSInteger selectRow);


@interface ZJCCourseListView : UIView <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic ,strong) UILabel * titleLabel;
@property (nonatomic ,strong) UITableView * tableView;
@property (nonatomic ,strong) NSMutableArray * dataSource;
@property (nonatomic ,copy) NSString * titleString;

@property (nonatomic ,strong) UIView * sectionBackView;
@property (nonatomic ,strong) UILabel * sectionLabel;

@property (nonatomic ,copy) courCellSelected cellDidSelected;

@end
