//
//  NSString+MD5String.h
//  CCRA
//
//  Created by htkg on 16/3/23.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5String)

// MD5 加密小写字母
- (NSString*)md532BitLower;
// MD5 加密大写字母
- (NSString*)md532BitUpper;

@end
