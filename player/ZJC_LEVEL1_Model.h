//
//  ZJC_LEVEL1_Model.h
//  CCRA
//
//  Created by htkg on 16/3/30.
//  Copyright © 2016年 htkg. All rights reserved.
//


/**
 *  @author XiaoChuan, 16-03-30 16:03:41
 *  
 *  这个是  章  的模型.  数据带 章标题
 */



#import <Foundation/Foundation.h>

@interface ZJC_LEVEL1_Model : NSObject

@property (nonatomic ,strong) NSString * name;    // 章 标题
@property (strong,nonatomic) NSString * sonCnt;   // 含有的 节 数量



@property (nonatomic ,copy) NSString * myid;          
@property (nonatomic ,copy) NSString * parentid;
@property (nonatomic ,copy) NSString * cover;
@property (nonatomic ,copy) NSString * eid;
@property (nonatomic ,copy) NSString * studybar;
@property (nonatomic ,copy) NSString * videoid;
@property (nonatomic ,copy) NSString * ispaper;
@property (nonatomic ,copy) NSString * videoduration;

@end
