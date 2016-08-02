//
//  ZJC_LEVEL0_Model.h
//  CCRA
//
//  Created by htkg on 16/3/30.
//  Copyright © 2016年 htkg. All rights reserved.
//


/**
 *  @author XiaoChuan, 16-03-30 16:03:41
 *  
 *  这个是  课程  的模型.  数据带 图片+标题+课时+下载数
 */


#import <Foundation/Foundation.h>

@interface ZJC_LEVEL0_Model : NSObject


@property (nonatomic ,copy) NSString * myid;          
@property (nonatomic ,copy) NSString * parentid;
@property (nonatomic ,copy) NSString * name;          // 标题
@property (nonatomic ,copy) NSString * sumlessons;    // 课时数
@property (copy, nonatomic) NSString * cover;         // 远程图片链接
@property (nonatomic ,copy) NSString * eid;
@property (nonatomic ,copy) NSString * studybar;
@property (nonatomic ,copy) NSString * videoid;
@property (nonatomic ,copy) NSString * ispaper;
@property (nonatomic ,copy) NSString * videoduration;


@property (copy,nonatomic) NSString * headImgPath;     // 本地图片名,若不为空则优先于远程图片加载
@property (nonatomic ,copy) NSString * downNumber;     // 缓冲数量


@end
