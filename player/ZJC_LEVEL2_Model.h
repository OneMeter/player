//
//  ZJC_LEVEL2_Model.h
//  CCRA
//
//  Created by htkg on 16/3/30.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJC_LEVEL2_Model : NSObject

@property (nonatomic ,strong) NSString * name;
@property (nonatomic ,strong) NSString * timeNumber;

@property (nonatomic ,copy) NSString * myid;          
@property (nonatomic ,copy) NSString * parentid;
@property (nonatomic ,copy) NSString * cover;
@property (nonatomic ,copy) NSString * eid;
@property (nonatomic ,copy) NSString * studybar;
@property (nonatomic ,copy) NSString * videoid;
@property (nonatomic ,copy) NSString * ispaper;
@property (nonatomic ,copy) NSString * videoduration;

@end
