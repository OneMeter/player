//
//  ZJCCourceCatelogueTableViewCell.h
//  CCRA
//
//  Created by htkg on 16/3/29.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJCCourceCatalogueSmallModel.h"


@interface ZJCCourceCatelogueTableViewCell : UITableViewCell

@property (nonatomic ,strong) ZJCCourceCatalogueSmallModel * model;
@property (nonatomic ,assign) CGFloat edgeLineSize;
@property (nonatomic ,strong) NSIndexPath * cellIndexpath;
@property (nonatomic ,strong) NSIndexPath * maxIndexPath;

@end
