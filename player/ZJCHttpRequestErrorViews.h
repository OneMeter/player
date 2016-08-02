//
//  ZJCHttpRequestErrorViews.h
//  CCRA
//
//  Created by htkg on 16/5/13.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @brief 重新请求按钮
 */
typedef void(^RequestRepetBlock)(UIButton * button);

@interface ZJCHttpRequestErrorViews : UIView

@property (nonatomic ,copy) RequestRepetBlock requestRepetButtonClicked;

@end
