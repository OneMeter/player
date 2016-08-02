//
//  ZJCCourceCatalogueSmallModel.h
//  CCRA
//
//  Created by htkg on 16/4/11.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <JSONModel/JSONModel.h>

// json解析的需求     在小模型里面声明一个同名协议,并不需要添加任何东西
// 然而并没有用上...
@protocol ZJCCourceCatalogueSmallModel <NSObject>

@end

@interface ZJCCourceCatalogueSmallModel : JSONModel

@property (nonatomic ,copy) NSString * id;
@property (nonatomic ,copy) NSString * name;
@property (nonatomic ,copy) NSString * cover;
@property (nonatomic ,copy) NSString * videoduration;
@property (nonatomic ,copy) NSString * studybar;
@property (nonatomic ,copy) NSString * videoid;
@property (nonatomic ,copy) NSString * eid;
@property (nonatomic ,copy) NSString * isapaper;
@property (nonatomic ,strong) NSArray * son;

@end
