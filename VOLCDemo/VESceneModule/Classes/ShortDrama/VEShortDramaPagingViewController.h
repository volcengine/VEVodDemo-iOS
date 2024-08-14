//
//  MXMyProgramViewController.h
//  VOLCDemo
//

#import "VESelectionViewController.h"

typedef NS_ENUM(NSUInteger, VEShortDramaType) {
    VEShortDramaTypeDrama = 0,
    VEShortDramaTypeRecommend,
    
    VEShortDramaTypeCount
};

@interface VEShortDramaPagingViewController : VESelectionViewController

- (instancetype)initWithDefaultType:(VEShortDramaType)type;

@end
