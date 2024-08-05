//
//  VEPlayerSeekState.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VEPlayerSeekStage) {
    VEPlayerSeekStageNone = 0,
    VEPlayerSeekStageSliderBegin,
    VEPlayerSeekStageSliderChanging,
    VEPlayerSeekStageSliderEnd,
    VEPlayerSeekStageSliderCancel
};

@interface VEPlayerSeekState : NSObject

@property (nonatomic, assign) VEPlayerSeekStage seekStage;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
