//
//  AFHTTPRequestOperationManager+ZJCAFHTTPRequestOperationManager.m
//  LanShan
//
//  Created by 小川 on 15-11-19.
//  Copyright (c) 2015年 iChuan. All rights reserved.
//

#import "AFHTTPRequestOperationManager+ZJCAFHTTPRequestOperationManager.h"

@implementation AFHTTPRequestOperationManager (ZJCAFHTTPRequestOperationManager)

+ (void)GET:(NSString *)urlString parameter:(id)parameter success:(succedBlock)succedBlock failure:(failedBlick)failedBlick{
    // 缓存管理类的单例
    ZJCCache * cacheManager = [ZJCCache shareInstence];
    NSData * data = [cacheManager getDataWithNameString:urlString];
    // 判断是否需要重新请求数据
    if (data) {
        logdebug(@"读取到缓存");
        succedBlock(data);
    }else{
        logdebug(@"缓存到本地");
        AFHTTPRequestOperationManager * requestManager = [AFHTTPRequestOperationManager manager];
        requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [requestManager GET:urlString parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // 存入缓存
            [cacheManager saveWithData:responseObject andNameString:urlString];
            succedBlock(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failedBlick(error);
        }];
    }
}




+ (void)POST:(NSString *)urlString parameter:(id)parameter success:(succedBlock)succedBlock failure:(failedBlick)failedBlock{
    AFHTTPRequestOperationManager * requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    [requestManager POST:urlString parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 回调成功
        succedBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 回调失败
        failedBlock(error);
    }];
}






@end
