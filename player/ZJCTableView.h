//
//  ZJCTableView.h
//  CCRA
//
//  Created by htkg on 16/4/5.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ZJCTableViewEditingStatusEdit = 1,
    ZJCTableViewEditingStatusNone
}ZJCTableViewEditingStatus;

@interface ZJCTableView : UITableView

@property (nonatomic ,assign)  ZJCTableViewEditingStatus editStatus;

@end
