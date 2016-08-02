//
//  ZJCNSUserDefault.m
//  HR
//
//  Created by htkg on 16/1/7.
//  Copyright © 2016年 htkg. All rights reserved.
//


#import "ZJCNSUserDefault.h"

@implementation ZJCNSUserDefault


// 存
+ (void)saveUsingNSUserDefaultWithDataType:(ZJCDataType)dataType andKey:(NSString *)key andObject:(id)object{
    // 获取本地缓存类
    NSUserDefaults * defaultUserInfor = [NSUserDefaults standardUserDefaults];
    // 获取存有所有本地用户信息的 Infor"字典"
    NSMutableDictionary * allUserInfor = [NSMutableDictionary dictionaryWithDictionary:[defaultUserInfor objectForKey:AllUserInfor_Key]];
    if (!allUserInfor) {
        allUserInfor = [NSMutableDictionary dictionary];
    }
    
    //////////////////////////////////////////////
    // 根据给出的"ZJCDataType"的不同,处理不同的操作
    // 1.NSUserDefault存有很多不同的信息
    // 2.每个信息不可以互相糅杂
    switch (dataType) {
        case ZJCJobSearchHistory: // "搜索历史"相关
        {
            // 取出"allUserInfor"里面存有的"搜索历史"数组,必须为 mutable
            // 将数据存进去
            NSMutableArray * historyArr = [NSMutableArray arrayWithArray:[allUserInfor objectForKey:SearchHistory]];
            if (!historyArr) {
                historyArr = [NSMutableArray array];
                [historyArr addObject:object];
            }else{
                for (NSString*tempObject in historyArr) {
                    // 如果原来有存的,那么不需要重新存入
                    if ([tempObject isEqualToString:object]) {
                        return;
                    }
                }
                // 如果原来没有存入过的,那么需要重新存入
                [historyArr addObject:object];
            }
            // 放回"allUserInfor"
            [allUserInfor removeObjectForKey:SearchHistory];
            [allUserInfor setObject:historyArr forKey:SearchHistory];
            // 存储到NSUserDefault里面去
            [defaultUserInfor removeObjectForKey:AllUserInfor_Key];
            [defaultUserInfor setObject:allUserInfor forKey:AllUserInfor_Key];
            [defaultUserInfor synchronize];
        }
            break;
            
            
        case ZJCUserInfor:  // 用户登陆相关
        {
            // 取出"AllUserInfor"里面存有的"搜索历史"字典,必须为Mutable
            NSMutableDictionary * userLoadInfor = [NSMutableDictionary dictionaryWithDictionary:[allUserInfor objectForKey:UserLoadInfor_Key]];
            if (!userLoadInfor) {
                // 如果不存在该字典
                userLoadInfor = [NSMutableDictionary dictionary];
            }
            // 这里不用判断是否是新的信息,只需要存入本地就行了
            [userLoadInfor removeAllObjects];
            userLoadInfor = [NSMutableDictionary dictionaryWithDictionary:object];  // 将后台请求回的字典存入到本地
//            // 因为安卓后台null数据类型不识别,所以需要将其转换为  @""
//            NSString * str = userLoadInfor[@"icon"];
//            if ([str isKindOfClass:[NSNull class]]) {
//                str = @"";
//            }
//            [userLoadInfor removeObjectForKey:@"icon"];
//            [userLoadInfor setObject:str forKey:@"icon"];
            // 放回"allUserInfor"
            [allUserInfor removeObjectForKey:UserLoadInfor_Key];
            [allUserInfor setObject:userLoadInfor forKey:UserLoadInfor_Key];
            // 存储到NSUserDefault里面去
            [defaultUserInfor removeObjectForKey:AllUserInfor_Key];
            [defaultUserInfor setObject:allUserInfor forKey:AllUserInfor_Key];
            [defaultUserInfor synchronize];
        }
            break;
            
            
        case ZJCString:
        {
            logdebug(@"待需求");
        }
            break;
        default:
            break;
    }
}


// 删
+ (void)removeDataUsingNSUserDefaultWithDataType:(ZJCDataType)dataType andKey:(NSString *)key{
    // 获取本地缓存类
    NSUserDefaults * defaultUserInfor = [NSUserDefaults standardUserDefaults];
    // 获取存有所有本地用户信息的 Infor"字典"
    NSMutableDictionary * allUserInfor = [NSMutableDictionary dictionaryWithDictionary:[defaultUserInfor objectForKey:AllUserInfor_Key]];
    if (!allUserInfor) {
        return;
    }
    // 分类处理
    switch (dataType) {
        case ZJCJobSearchHistory: // "清除历史记录搜索历史"相关
        {
            // 取出"allUserInfor"里面存有的"搜索历史"数组,必须为 mutable
            // 将数据存进去
            NSMutableArray * historyArr = [NSMutableArray arrayWithArray:[allUserInfor objectForKey:SearchHistory]];
            if (!historyArr) {
                return;
            }else{
                // 如果有的话,干掉所有的数组元素
                [historyArr removeAllObjects];
            }
            // 放回"allUserInfor"
            [allUserInfor removeObjectForKey:SearchHistory];
            [allUserInfor setObject:historyArr forKey:SearchHistory];
            // 存储到NSUserDefault里面去
            [defaultUserInfor removeObjectForKey:AllUserInfor_Key];
            [defaultUserInfor setObject:allUserInfor forKey:AllUserInfor_Key];
            [defaultUserInfor synchronize];
        }
            break;
            
            
        case ZJCUserInfor:  // 用户登陆相关
        {
            // 取出"AllUserInfor"里面存有的"用户信息"字典,必须为Mutable
            NSMutableDictionary * userLoadInfor = [NSMutableDictionary dictionaryWithDictionary:[allUserInfor objectForKey:UserLoadInfor_Key]];
            if (!userLoadInfor) {
                return;
            }else{
                // 直接干掉所有的数据就行了
                [userLoadInfor removeAllObjects];
            }
            // 放回"allUserInfor"
            [allUserInfor removeObjectForKey:UserLoadInfor_Key];
            [allUserInfor setObject:userLoadInfor forKey:UserLoadInfor_Key];
            // 存储到NSUserDefault里面去
            [defaultUserInfor removeObjectForKey:AllUserInfor_Key];
            [defaultUserInfor setObject:allUserInfor forKey:AllUserInfor_Key];
            [defaultUserInfor synchronize];
        }
            break;
            
            
        case ZJCString:  //
        {
            logdebug(@"待需求");
        }
            break;
        default:
            break;
    }
}


// 取
+ (id)getDataUsingNSUserDefaultWithDataType:(ZJCDataType)dataType andKey:(NSString *)key{
    // 获取本地缓存类
    NSUserDefaults * defaultUserInfor = [NSUserDefaults standardUserDefaults];
    // 获取存有所有本地用户信息的 Infor"字典"
    NSMutableDictionary * allUserInfor = [NSMutableDictionary dictionaryWithDictionary:[defaultUserInfor objectForKey:AllUserInfor_Key]];
    if (!allUserInfor) {
        return nil;
    }
    // 分类处理
    switch (dataType) {
        case ZJCJobSearchHistory: // "搜索历史"相关
        {
            // 取出"allUserInfor"里面存有的"搜索历史"数组,必须为 mutable
            // 将数据存进去
            NSMutableArray * historyArr = [NSMutableArray arrayWithArray:[allUserInfor objectForKey:SearchHistory]];
            if (!historyArr) {
                return nil;
            }else{
                // 返回查询到的数组
                return historyArr;
            }
        }
            break;
            
            
        case ZJCUserInfor:  // 用户登陆相关
        {
            // 取出"AllUserInfor"里面存有的"搜索历史"字典,必须为Mutable
            NSMutableDictionary * userLoadInfor = [NSMutableDictionary dictionaryWithDictionary:[allUserInfor objectForKey:UserLoadInfor_Key]];
            if (!userLoadInfor) {
                return nil;
            }else{
                // 返回查询到得字典键值对应的信息
                return userLoadInfor[key];
            }
        }
            break;
            
            
        case ZJCString:
        {
            logdebug(@"待需求");
        }
            break;
        default:
            break;
    }
    return nil;
}



@end
