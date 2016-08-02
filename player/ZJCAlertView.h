//
//  ZJCAlertView.h
//  ZJCAlertView
//
//  Created by htkg on 16/1/25.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIAlertController.h>

@class UIAlertController;

// 定制 回调完成状态Block
typedef void(^myCompletion)();

@interface ZJCAlertView : NSObject

// 添加alert
+ (void)presentAlertWithAlertTitle:(NSString *)alertTitle andAlertMessage:(NSString *)alertMessage andAlertStyle:(UIAlertControllerStyle)alertStyle andAlertActionArray:(NSArray *)actionArr andSupportController:(UIViewController *)controller completion:(myCompletion)completion;

// 延迟后自动消失的alert
+ (void)presentAlertWithAlertTitle:(NSString *)alertTitle andAlertMessage:(NSString *)alertMessage andAlertStyle:(UIAlertControllerStyle)alertStyle andSupportController:(UIViewController *)controller completion:(myCompletion)completion andDelay:(NSUInteger)delaySecond;

@end
