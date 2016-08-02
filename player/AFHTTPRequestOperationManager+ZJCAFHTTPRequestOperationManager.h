//
//  AFHTTPRequestOperationManager+ZJCAFHTTPRequestOperationManager.h
//  LanShan
//
//  Created by 小川 on 15-11-19.
//  Copyright (c) 2015年 iChuan. All rights reserved.
//

#import <AFHTTPRequestOperationManager.h>
#import "ZJCCache.h"

typedef void(^succedBlock)(id responseObject);
typedef void(^failedBlick)(NSError * error);


@interface AFHTTPRequestOperationManager (ZJCAFHTTPRequestOperationManager)

+ (void)GET:(NSString *)urlString parameter:(id)parameter success:(succedBlock)succedBlock failure:(failedBlick)failedBlick;

@end
