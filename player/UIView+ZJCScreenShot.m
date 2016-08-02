//
//  UIView+ZJCScreenShot.m
//  CCRA
//
//  Created by htkg on 16/4/7.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "UIView+ZJCScreenShot.h"

@implementation UIView (ZJCScreenShot)

- (UIImage *)convertViewToImage{
    UIGraphicsBeginImageContext(self.bounds.size); 
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES]; 
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext(); 
    UIGraphicsEndImageContext(); 
    
    return image; 
    return nil;  
}

@end
