//
//  ZJCCache.h
//  LanShan
//
//  Created by 小川 on 15-11-19.
//  Copyright (c) 2015年 iChuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJCCache : NSObject

// 单例
+ (ZJCCache *)shareInstence;

// 缓存到本地的实现方法
// 存
- (void)saveWithData:(NSData *)data andNameString:(NSString *)urlString;
// 取
- (NSData *)getDataWithNameString:(NSString *)urlString;


@end
