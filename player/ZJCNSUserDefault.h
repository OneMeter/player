//
//  ZJCNSUserDefault.h
//  HR
//
//  Created by htkg on 16/1/7.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <Foundation/Foundation.h>

// 数据类型参数枚举
typedef enum {
    ZJCJobSearchHistory = 0,
    ZJCUserInfor,
    ZJCString
}ZJCDataType;




@interface ZJCNSUserDefault : NSObject

// 存入
+ (void)saveUsingNSUserDefaultWithDataType:(ZJCDataType)dataType andKey:(NSString *)key andObject:(id)object;

// 删除
+ (void)removeDataUsingNSUserDefaultWithDataType:(ZJCDataType)dataType andKey:(NSString *)key;

// 取出
+ (id)getDataUsingNSUserDefaultWithDataType:(ZJCDataType)dataType andKey:(NSString *)key;

@end
