//
//  ZJCPopDownloadListViewModel.h
//  CCRA
//
//  Created by htkg on 16/5/23.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <JSONModel/JSONModel.h>

// 区分是section头视图   还是rowcell
typedef enum {
    ZJCDownloadListTableViewCellTypeSection = 1,
    ZJCDownloadListTableViewCellTypeRow
}ZJCDownloadListTableViewCellType;


@interface ZJCPopDownloadListViewModel : JSONModel

@property (nonatomic ,assign) ZJCDownloadListTableViewCellType cellType;   // cell类型(组类型和cell类型)
@property (nonatomic ,assign) BOOL isselected;             // 选中标记
@property (nonatomic ,assign) BOOL isHaveSelectButton;     // 含有选中按钮
@property (nonatomic ,assign) BOOL isHaveSepereter;        // 分割线标记
@property (nonatomic ,strong) ZJCPopDownloadListViewModel * parentModel;  // 父亲节点数据

@property (nonatomic ,copy) NSString * id;
@property (nonatomic ,copy) NSString * name;
@property (nonatomic ,copy) NSString * cover;
@property (nonatomic ,copy) NSString * videoduration;
@property (nonatomic ,copy) NSString * studybar;
@property (nonatomic ,copy) NSString * videoid;
@property (nonatomic ,copy) NSString * eid;
@property (nonatomic ,copy) NSString * ispaper;
@property (nonatomic ,strong) NSArray * son;

@end
