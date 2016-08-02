//
//  ZJCDownItem.m
//  CCRA
//
//  Created by htkg on 16/5/4.
//  Copyright © 2016年 htkg. All rights reserved.
//

#import "ZJCDownItem.h"

@implementation ZJCDownItem

- (instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        _myid         = [dic objectForKey:@"myid"];
        _myparentid   = [dic objectForKey:@"myparentid"];
        _vedioid      = [dic objectForKey:@"vedioid"];
        _name         = [dic objectForKey:@"name"];
        _maxcount     = [dic objectForKey:@"maxcount"];
        _imageurl     = [dic objectForKey:@"imageurl"];
        _isover       = [dic objectForKey:@"isover"];
        _destination  = [NSString stringWithFormat:@"%@/%@%@.pcm",DWPlayer_Destion,_myid,_vedioid];
        _downloader   = [[DWDownloader alloc] initWithUserId:DWACCOUNT_USERID andVideoId:_vedioid key:DWACCOUNT_APIKEY destinationPath:_destination];
        _downloader.timeoutSeconds = DWPlayer_RequestOutTime;
    }
    return self;
}

- (instancetype)initWithItem:(ZJCDownItem *)item{
    if (self = [super init]) {
        _myid         = item.myid;
        _myparentid   = item.myparentid;
        _vedioid      = item.vedioid;
        _name         = item.name;
        _maxcount     = item.maxcount;
        _imageurl     = item.imageurl;
        _isover       = item.isover;
        _destination  = [NSString stringWithFormat:@"%@/%@%@.pcm",DWPlayer_Destion,_myid,_vedioid];
        _downloader   = item.downloader;
        _downloader.timeoutSeconds = DWPlayer_RequestOutTime;
    }
    return self;
}


@end
