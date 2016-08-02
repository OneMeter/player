//
//  ZJCCourceCatalogueModel.h
//  CCRA
//
//  Created by htkg on 16/3/29.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "ZJCCourceCatalogueSmallModel.h"

@interface ZJCCourceCatalogueModel : JSONModel

@property (nonatomic ,copy) NSString * id;
@property (nonatomic ,copy) NSString * name;
@property (nonatomic ,copy) NSString * cover;
@property (nonatomic ,copy) NSString * videoduration;
@property (nonatomic ,copy) NSString * studybar;
@property (nonatomic ,copy) NSString * videoid;
@property (nonatomic ,copy) NSString * eid;
@property (nonatomic ,copy) NSString * ispaper;
@property (nonatomic ,strong) NSArray<ZJCCourceCatalogueSmallModel>* son;

@end
