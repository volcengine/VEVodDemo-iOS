//
//  VEVideoPlayerPipController.m
//  VOLCDemo
//
//  Created by litao.he on 2025/3/18.
//

#import "VEVideoPlayerPipController.h"
#import "VEPlayerContextMacros.h"
#import <TTSDKFramework/TTVideoEngine+Options.h>

typedef struct EngineVideoWrapperContext{
    EngineVideoWrapper *videoWrapper;
    void *playerController;
}EngineVideoWrapperContext;

@implementation VEVideoPlayerPipDisplayView

+ (Class)layerClass {
  return [AVSampleBufferDisplayLayer class];
}

@end

@interface VEVideoPlayerPipController () <AVPictureInPictureControllerDelegate, AVPictureInPictureSampleBufferPlaybackDelegate>

// Pip
@property (nonatomic, strong) AVPictureInPictureController *pipController;

@end

@implementation VEVideoPlayerPipController

+ (instancetype)shared {
    static VEVideoPlayerPipController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VEVideoPlayerPipController alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.displayView = [[VEVideoPlayerPipDisplayView alloc] init];
        self.displayView.userInteractionEnabled = NO;
        self.displayView.clipsToBounds = YES;
        self.displayView.alpha = 0.0;
        self.displayLayer = (AVSampleBufferDisplayLayer *)self.displayView.layer;
        self.displayLayer.opaque = YES;
        self.displayLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc] initWithSampleBufferDisplayLayer:self.displayLayer playbackDelegate:self];
        self.pipController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
        self.pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
        self.pipController.requiresLinearPlayback = YES;
        self.pipController.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [self stopPip];
    self.pipController = nil;
    self.displayView = nil;
    self.displayLayer = nil;
}

- (void)setVideoViewMode:(VEVideoViewMode)videoViewMode {
    switch (videoViewMode) {
        case VEVideoViewModeModeFill:
            _displayLayer.videoGravity = AVLayerVideoGravityResize;
            break;
        case VEVideoViewModeAspectFit:
            _displayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case VEVideoViewModeAspectFill:
            _displayLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        default:
            _displayLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
    }
}

- (void)startPip {
    if (self.pipController.isPictureInPicturePossible) {
        [self.pipController startPictureInPicture];
    } else {
        NSLog(@"====== pip not possible now");
    }
}

- (void)stopPip {
    [self.pipController stopPictureInPicture];
}

- (BOOL)isPipActive {
    return self.pipController.isPictureInPictureActive;
}

- (void)invalidatePlaybackState {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pipController invalidatePlaybackState];
    });
}

- (EngineVideoWrapper *)createVideoWrapper:(id)playerController {
    EngineVideoWrapper *videoWrapper = malloc(sizeof(EngineVideoWrapper));
    videoWrapper->process = process;
    videoWrapper->release = release;

    EngineVideoWrapperContext *context = malloc(sizeof(EngineVideoWrapperContext));
    context->videoWrapper = videoWrapper;
    context->playerController = (__bridge void *)playerController;

    videoWrapper->context = context;
    return videoWrapper;
}

static void process(void *context, CVPixelBufferRef frame, int64_t timestamp) {
    if (!context) {
        return;
    }
    if (!frame) {
        NSLog(@"pip invalid frame: %p", (void *)(frame));
    }

    EngineVideoWrapperContext *ctx = (EngineVideoWrapperContext *)context;
    id playerController = (__bridge id)ctx->playerController;
    if (playerController == [VEVideoPlayerPipController shared].currentController) {
        CFTimeInterval currentTime = CACurrentMediaTime();
        static CFTimeInterval prevInvalidateTime = 0;
        if (currentTime - prevInvalidateTime >= 1.0) {
            prevInvalidateTime = currentTime;
            [[VEVideoPlayerPipController shared] invalidatePlaybackState];
        }
        [VEVideoPlayerPipController __dispatchPixelBuffer:frame];
    }
}

static void release(void *context) {
    if (!context) {
        return;
    }

    EngineVideoWrapperContext *ctx = (EngineVideoWrapperContext *)(context);
    free(ctx->videoWrapper);
    free(ctx);
}

+ (void)__dispatchPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (!pixelBuffer) {
        NSLog(@"volc--pixelBuffer invalid");
        return;
    }
    CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    if (!(result == 0 && videoInfo != NULL)) {
        return;
    }

    CMSampleBufferRef sampleBuffer = NULL;
    result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    if (!(result == 0 && sampleBuffer != NULL)) {
        return;
    }

    CFRelease(videoInfo);
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);

    [self enqueueSampleBuffer:sampleBuffer toLayer:[VEVideoPlayerPipController shared].displayLayer];

    CFRelease(sampleBuffer);
}

+ (void)enqueueSampleBuffer:(CMSampleBufferRef)sampleBuffer toLayer:(AVSampleBufferDisplayLayer*)layer {
    if (!sampleBuffer || !layer.readyForMoreMediaData) {
        NSLog(@"volc--sampleBuffer invalid");
        return;
    }
    if (@available(iOS 16.0, *)) {
        if (layer.status == AVQueuedSampleBufferRenderingStatusFailed) {
            NSLog(@"volc--sampleBufferLayer error:%@",layer.error);
            [layer flush];
        }
    } else {
        [layer flush];
    }
    if (@available(iOS 15.0, *)) {
        [layer enqueueSampleBuffer:sampleBuffer];
    } else {
        VEPlayerContextRunOnMainThread(^{
            [layer enqueueSampleBuffer:sampleBuffer];
        });
    }
}

#pragma mark - AVPictureInPictureControllerDelegate
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"volc--pictureInPictureControllerWillStartPictureInPicture");
    [TTVideoEngine setGlobalForKey:VEGSKeyIgnoreGlActive value:@(1)];
    if ([self.delegate respondsToSelector:@selector(willStartPictureInPicture)]) {
        [self.delegate willStartPictureInPicture];
    }
    [self invalidatePlaybackState];
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"volc--pictureInPictureControllerDidStartPictureInPicture");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
failedToStartPictureInPictureWithError:(NSError *)error {
    [TTVideoEngine setGlobalForKey:VEGSKeyIgnoreGlActive value:@(0)];
    NSLog(@"volc--failedToStartPictureInPictureWithError");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"volc--restoreUserInterfaceForPictureInPictureStopWithCompletionHandler");
    completionHandler(true);
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"volc--pictureInPictureControllerWillStopPictureInPicture");
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"volc--pictureInPictureControllerDidStopPictureInPicture");
    if ([self.delegate respondsToSelector:@selector(didStopPictureInPicture)]) {
        [self.delegate didStopPictureInPicture];
    }
    [TTVideoEngine setGlobalForKey:VEGSKeyIgnoreGlActive value:@(0)];
}

#pragma mark - AVPictureInPictureSampleBufferPlaybackDelegate
- (BOOL)pictureInPictureControllerIsPlaybackPaused:(nonnull AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"volc--pictureInPictureControllerIsPlaybackPaused");
    if ([self.delegate respondsToSelector:@selector(getPlaybackState)]) {
        VEVideoPlaybackState state = [self.delegate getPlaybackState];
        if (state != VEVideoPlaybackStatePaused && state != VEVideoPlaybackStateStopped && state != VEVideoPlaybackStateError) {
            return NO;
        }
    }
    return YES;
}

- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"volc--pictureInPictureControllerTimeRangeForPlayback");
    VEVideoPlaybackState state = VEVideoPlaybackStateUnkown;
    if ([self.delegate respondsToSelector:@selector(getPlaybackState)]) {
        state = [self.delegate getPlaybackState];
    }
    if (state != VEVideoPlaybackStatePlaying && state != VEVideoPlaybackStatePaused) {
        return CMTimeRangeMake(CMTimeMake(0, 1), CMTimeMake(100, 1));
    }

    CMTimeRange timeRange;
    if ([self.delegate respondsToSelector:@selector(getDuration)] && [self.delegate respondsToSelector:@selector(getPosition)]) {
        NSInteger pos = [self.delegate getPosition];
        NSInteger dura = [self.delegate getDuration];
        NSInteger interval = dura - pos;
        NSInteger timeBase = CACurrentMediaTime();
        NSInteger start = timeBase - pos;
        NSInteger end = timeBase + interval;
        CMTime t1 = CMTimeMakeWithSeconds(start, 1);
        CMTime t2 = CMTimeMakeWithSeconds(end, 1);
        timeRange = CMTimeRangeFromTimeToTime(t1, t2);
    } else {
        timeRange = CMTimeRangeMake(kCMTimeNegativeInfinity, kCMTimePositiveInfinity);
    }

    return timeRange;
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
         didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
    NSLog(@"volc--didTransitionToRenderSize");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController setPlaying:(BOOL)playing {
    NSLog(@"volc--pictureInPictureController setPlaying");
    if ([self.delegate respondsToSelector:@selector(setPlaying:)]) {
        [self.delegate setPlaying:playing];
    }
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
                    skipByInterval:(CMTime)skipInterval
                 completionHandler:(void (^)(void))completionHandler {
    NSLog(@"volc--pictureInPictureController skipByInterval");
}
@end
