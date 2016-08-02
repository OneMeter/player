#import <UIKit/UIKit.h>
#import "DWSDK.h"



typedef void(^PlyerCurrentPlayDuration)(NSString * vedioId,NSInteger duration,NSString * title);


@interface DWCustomPlayerViewController : UIViewController

@property (copy, nonatomic) NSString * videoId;
@property (nonatomic ,copy) NSString * lessonId;
@property (copy, nonatomic) NSString *videoLocalPath;

@property (nonatomic ,copy) NSString * titleLabelString;
@property (nonatomic ,assign) NSInteger userWantTimePlayBackTime;

@property (nonatomic ,copy) PlyerCurrentPlayDuration playerCurrentDurationBlock;

@end
