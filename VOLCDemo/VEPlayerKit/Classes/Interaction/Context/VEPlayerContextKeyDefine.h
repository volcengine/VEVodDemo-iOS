//
//  VEPlayerContextKeyDefine.h
//  VEPlayerKit
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Engine
extern NSString * const VEPlayerContextKeyBeforePlayAction;
extern NSString * const VEPlayerContextKeyPlayAction;
extern NSString * const VEPlayerContextKeyPauseAction;
extern NSString * const VEPlayerContextKeyStopAction;
extern NSString * const VEPlayerContextKeyPlaybackState;
extern NSString * const VEPlayerContextKeyLoadState;
extern NSString * const VEPlayerContextKeyEnginePrepared;
extern NSString * const VEPlayerContextKeyReadyForDisplay;
extern NSString * const VEPlayerContextKeyReadyToPlay;
extern NSString * const VEPlayerContextKeyPlaybackDidFinish;
extern NSString * const VEPlayerContextKeyVolumeChanged;
extern NSString * const VEPlayerContextKeyPlaybackSpeedChanged; // TODO
extern NSString * const VEPlayerContextKeyResolutionChanged; // TODO
extern NSString * const VEPlayerContextKeyRadioModeChanged; // TODO
extern NSString * const VEPlayerContextKeyScaleModeChanged; // TODO
extern NSString * const VEPlayerContextKeyMediaInfoIDChanged; // TODO


#pragma mark - Player control
extern NSString * const VEPlayerContextKeyControlTemplateChanged;
extern NSString * const VEPlayerContextKeyShowControl;
extern NSString * const VEPlayerContextKeyLockControl;
extern NSString * const VEPlayerContextKeyControlViewSingleTap;
extern NSString * const VEPlayerContextKeyPlayButtonSingleTap;
extern NSString * const VEPlayerContextKeyPlayButtonDoubleTap;

#pragma mark - Player UI
extern NSString * const VEPlayerContextKeyVideoTitleChanged;
extern NSString * const VEPlayerContextKeyShowPanel;
extern NSString * const VEPlayerContextKeySliderMarkPoints;
extern NSString * const VEPlayerContextKeySliderCirclePoints;

#pragma mark - Seek
extern NSString * const VEPlayerContextKeySliderSeekBegin;
extern NSString * const VEPlayerContextKeySliderChanging;
extern NSString * const VEPlayerContextKeySliderCancel;
extern NSString * const VEPlayerContextKeySliderSeekEnd;

#pragma mark - Rotate screen
extern NSString * const VEPlayerContextKeyRotateScreen;
extern NSString * const VEPlayerContextKeySupportsPortaitFullScreen;

#pragma mark - Loading
extern NSString * const VEPlayerContextKeyShowLoadingNetWorkSpeed;
extern NSString * const VEPlayerContextKeyStartLoading;
extern NSString * const VEPlayerContextKeyFinishLoading;

#pragma mark - Player Speed
extern NSString * const VEPlayerContextKeySpeedTipViewShowed;

#pragma mark - DataModel
extern NSString * const VEPlayerContextKeyDataModelChanged;

#pragma mark - ShortDrama
extern NSString * const VEPlayerContextKeyShortDramaDataModelChanged;
extern NSString * const VEPlayerContextKeyShortDramaShowPayModule;

NS_ASSUME_NONNULL_END

