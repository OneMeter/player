//
//  ZJCVersionUpdatedView.h
//  CCRA
//
//  Created by htkg on 16/5/13.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @brief 立即更新Block
 */
typedef void(^UpdateButtonClicked)(UIButton * button);

/**
 *  @brief 暂不更新Block
 */
typedef void(^NotUpdateButtonClicked)(UIButton * button);



@interface ZJCVersionUpdatedView : UIView

@property (nonatomic ,copy) UpdateButtonClicked updateBlock;
@property (nonatomic ,copy) NotUpdateButtonClicked notUpdateBlock;

- (instancetype)initWithFrame:(CGRect)frame withVerisionNumber:(NSString *)versionNumber andVersionInfor:(NSDictionary *)versionInfor;
- (void)showAlert;
- (void)dismissAlert;

@end
