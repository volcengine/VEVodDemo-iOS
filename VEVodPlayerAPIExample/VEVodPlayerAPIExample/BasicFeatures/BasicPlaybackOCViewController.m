// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  BasicPlaybackOCViewController.m
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/27.
//

#import "BasicPlaybackOCViewController.h"
#import "VEAPIVideoModel.h"
#import "VEAPITools.h"
#import "VEAPIButton.h"
#import "VEAPIMediaSource.h"
#import <TTSDKFramework/TTSDKFramework.h>
#import <Masonry/Masonry.h>

@interface BasicPlaybackOCViewController () <TTVideoEngineDelegate, TTVideoEnginePreloadDelegate>

@property (nonatomic, strong) TTVideoEngine *engine;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, assign) CGFloat playStartTime;
@property (nonatomic, assign) NSInteger buttonNum;

@property (nonatomic, strong) UISlider *progressSliderForPlay;
@property (nonatomic, strong) UISlider *progressSliderForCache;
@property (nonatomic, strong) UISlider *progressSliderForSound;
@property (nonatomic, strong) UILabel *playLabel;
@property (nonatomic, strong) UILabel *cacheLabel;

@end

@implementation BasicPlaybackOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VEVodPlayerAPIExample - BasicPlaybackOCViewController");
    self.view.backgroundColor = [UIColor whiteColor];
    [self constructViews];
}

- (void)viewDidDisappear:(BOOL)animated {
    // 播放停止时需要主动移除定时器，避免产生内存泄漏
    [self.engine removeTimeObserver];
    // 移除视图
    [self.engine.playerView removeFromSuperview];
    // 停止播放，销毁 engine 实例，engine 实例不能再次被使用。
    [self.engine closeAysnc];
    self.engine = nil;
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    [super viewWillDisappear:animated];
}

- (void)constructViews {
    CGFloat topOffset = UIApplication.sharedApplication.statusBarFrame.size.height + self.navigationController.navigationBar.bounds.size.height;
    // 初始化播放器实例并以属性持有
    self.engine = [[TTVideoEngine alloc] initWithOwnPlayer:YES];
    // playerView 是播放器的显示视图，需要被添加业务父视图中并设置 playerView 的 frame
    [self.view addSubview:self.engine.playerView];
    [self.engine.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(topOffset);
        make.left.right.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.3);
    }];
    [self initPlayer];
    
    self.playLabel.text = NSLocalizedString(@"play_progress_label", NULL);
    [self.view addSubview:self.playLabel];
    [self.playLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(5);
        make.top.equalTo(self.engine.playerView.mas_bottom);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(30);
    }];
    
    [self.view addSubview:self.progressSliderForPlay];
    [self.progressSliderForPlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(10);
        make.top.equalTo(self.playLabel.mas_bottom).offset(3);
    }];
    
    self.cacheLabel.text = NSLocalizedString(@"cache_progress_label", NULL);
    [self.view addSubview:self.cacheLabel];
    [self.cacheLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(5);
        make.top.equalTo(self.progressSliderForPlay.mas_bottom);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(30);
    }];
    
    [self.view addSubview:self.progressSliderForCache];
    [self.progressSliderForCache mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(10);
        make.top.equalTo(self.cacheLabel.mas_bottom).offset(3);
    }];
    
    UILabel *controlLabel = [[UILabel alloc] init];
    controlLabel.text = NSLocalizedString(@"control_label", NULL);
    [self.view addSubview:controlLabel];
    [controlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressSliderForCache.mas_bottom).offset(3);
        make.left.equalTo(self.view).offset(5);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(30);
    }];
    NSArray *controlTitles = @[NSLocalizedString(@"control_play", NULL), NSLocalizedString(@"control_pause", NULL), NSLocalizedString(@"control_set_time", NULL)];
    [self constructButtons:controlTitles BelowLabel:controlLabel];
    
    UILabel *speedLabel = [[UILabel alloc] init];
    speedLabel.text = NSLocalizedString(@"speed_label", NULL);
    [self.view addSubview:speedLabel];
    [speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(controlLabel.mas_bottom).offset(41);
        make.left.equalTo(self.view).offset(5);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(30);
    }];
    NSArray *speedTitles = @[@"0.5", @"1.0", @"1.5", @"2.0"];
    [self constructButtons:speedTitles BelowLabel:speedLabel];
    
    UILabel *loopLabel = [[UILabel alloc] init];
    loopLabel.text = NSLocalizedString(@"loop_label", NULL);
    [self.view addSubview:loopLabel];
    [loopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(speedLabel.mas_bottom).offset(41);
        make.left.equalTo(self.view).offset(5);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(30);
    }];
    NSArray *loopTitles = @[@"false", @"true"];
    [self constructButtons:loopTitles BelowLabel:loopLabel];
    
    UILabel *muteLabel = [[UILabel alloc] init];
    muteLabel.text = NSLocalizedString(@"mute_label", NULL);
    [self.view addSubview:muteLabel];
    [muteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(loopLabel.mas_bottom).offset(41);
        make.left.equalTo(self.view).offset(5);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(30);
    }];
    NSArray *muteTitles = @[@"false", @"true"];
    [self constructButtons:muteTitles BelowLabel:muteLabel];
    
    UILabel *soundLabel = [[UILabel alloc] init];
    soundLabel.text = NSLocalizedString(@"sound_label", NULL);
    [self.view addSubview:soundLabel];
    [soundLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(muteLabel.mas_bottom).offset(41);
        make.left.equalTo(self.view).offset(5);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(30);
    }];
    [self.view addSubview:self.progressSliderForSound];
    [self.progressSliderForSound mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(10);
        make.top.equalTo(soundLabel.mas_bottom).offset(3);
    }];
    self.progressSliderForSound.value = self.engine.volume;
}

- (void)constructButtons:(NSArray <NSString *> *)titles BelowLabel:(UILabel *)label {
    for (int i = 0; i < titles.count; ++i) {
        VEAPIButton *button = [[VEAPIButton alloc] initWithTitle:titles[i]];
        [self.view addSubview:button];
        button.tag = self.buttonNum;
        self.buttonNum += 1;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label.mas_bottom).offset(3);
            make.left.equalTo(self.view).offset(80 * i + 3);
            make.width.mas_equalTo(75);
            make.height.mas_equalTo(35);
        }];
    }
}

- (void)inputPlayStartTime {
    // 设置指定起播时间
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"control_set_time", NULL) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok_label", NULL) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        //获取第1个输入框；
        UITextField *titleTextField = alertController.textFields.firstObject;
        self.playStartTime = titleTextField.text ? [titleTextField.text floatValue] : 0;
        NSLog(@"set start time: %@", titleTextField.text);
    }]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [NSString stringWithFormat:@"%@", @(self.playStartTime)];
    }];
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alertController animated:YES completion:nil];
}

- (void)initPlayer {
    // 设置 TTVideoEngineDelegate 回调
    self.engine.delegate = self;
    // 设置 TTVideoEnginePreloadDelegate 回调，可获得当前视频下载速度
    [TTVideoEngine ls_setPreloadDelegate:self];
    // 设置 directUrl 播放源
    NSString *videoUrl = [VEAPIVideoModel defaultVideoModel][0].videoUrl;
    TTVideoEngineUrlSource *urlSource = [VEAPIMediaSource initDirectUrlSource:videoUrl];
    [self.engine setVideoEngineVideoSource:urlSource];

    // 设置屏幕长亮
    // 方式一，通过系统 API 设置
//    [UIApplication sharedApplication].idleTimerDisabled = YES;
    // 方式二，通过 SDK 提供的 API 设置
    [self.engine setOptionForKey:VEKKeyPlayerIdleTimerAuto_NSInteger value:@(YES)];
    
    // 如果只想调整单个视频的音量，需要在 play 之前配置 AudioDevice
    [self.engine setOptionForKey:VEKKeyPlayerAudioDevice_ENUM value:@(TTVideoEngineDeviceAudioGraph)];
    
    // 内部封装 NSTimer 定时器，方便您在获取播放进度时，您也可以自己实现
    [self.engine addPeriodicTimeObserverForInterval:5  queue:dispatch_get_main_queue() usingBlock:^{
        // 这里获取当前播放进度，播放时长，可播放时长在 UI 上展示
        NSLog(@"VEVodPlayerAPIExample - currentPlaybackTime:%f, duration:%f, playableDuration:%f", self.engine.currentPlaybackTime, self.engine.duration, self.engine.playableDuration);
    }];

    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (void)updateProgress {
    // 获取播放时长
    CGFloat duration = self.engine.duration;
    CGFloat currentPlaybackTime = self.engine.currentPlaybackTime;
    CGFloat playableDuration = self.engine.playableDuration;
    if (duration > 0) {
        self.progressSliderForPlay.maximumValue = duration;
        self.progressSliderForCache.maximumValue = duration;
        // 获取当前播放位置
        self.progressSliderForPlay.value = currentPlaybackTime;
        // 获取缓存进度
        self.progressSliderForCache.value = playableDuration;
        self.playLabel.text = [NSString stringWithFormat:@"播放进度:%@/%@", [VEAPITools convertSecondsToStr:currentPlaybackTime], [VEAPITools convertSecondsToStr:duration]];
        self.cacheLabel.text = [NSString stringWithFormat:@"视频缓存进度:%@/%@", [VEAPITools convertSecondsToStr:playableDuration], [VEAPITools convertSecondsToStr:duration]];
    }
}

- (void)sliderValueChanged:(UISlider *)slider {
    if (slider.tag == 0) {
        // 播放完毕后如果还需正常 seek，需要做以下操作
        if (self.engine.playbackState == TTVideoEnginePlaybackStateStopped) {
            [self.engine play];
        }
        // currentTime 需要快进/快退到某个时间点
        [self.engine setCurrentPlaybackTime:slider.value complete:^(BOOL success) {
            // seek 操作状态完成回调
            NSLog(@"VEVodPlayerAPIExample - seek complete %@", @(success));
        } renderComplete:^{
            // seek 渲染完成回调
            NSLog(@"VEVodPlayerAPIExample - seek render complete");
        }];
    }else if (slider.tag == 2){
        self.engine.volume = slider.value;
    }
}

- (void)buttonTapped:(UIButton *)sender {
    switch (sender.tag) {
        case 0: {
            // 从指定时间起播，需在 play 之前设置
            [self.engine setOptionForKey:VEKKeyPlayerStartTime_CGFloat value:@(self.playStartTime)];
            // 开始播放
            [self.engine play];
            break;
        }
        case 1: {
            // 暂停播放
            [self.engine pause];
            break;
        }
        case 2: {
            [self inputPlayStartTime];
            break;
        }
        case 3: {
            // 设置播放速度
            self.engine.playbackSpeed = 0.5;
            break;
        }
        case 4: {
            // 设置播放速度
            self.engine.playbackSpeed = 1.0;
            break;
        }
        case 5: {
            // 设置播放速度
            self.engine.playbackSpeed = 1.5;
            break;
        }
        case 6: {
            // 设置播放速度
            self.engine.playbackSpeed = 2.0;
            break;
        }
        case 7: {
            // 关闭循环播放
            self.engine.looping = NO;
            break;
        }
        case 8: {
            // 开启循环播放
            self.engine.looping = YES;
            break;
        }
        case 9: {
            // 关闭静音
            self.engine.muted = NO;
            break;
        }
        case 10: {
            // 开启静音
            self.engine.muted = YES;
            break;
        }
        default:
            break;
    }
}

#pragma mark - TTVideoEngineDelegate

- (void)videoEngine:(TTVideoEngine *)videoEngine playbackStateDidChanged:(TTVideoEnginePlaybackState)playbackState {
    /// 播放状态（播放、暂停等）修改时会触发该方法
    NSLog(@"VEVodPlayerAPIExample - playbackStateDidChanged to %@", @(playbackState));
}

- (void)videoEngine:(TTVideoEngine *)videoEngine loadStateDidChanged:(TTVideoEngineLoadState)loadState {
    // 内部的加载状态，可以根据该方法显示或者隐藏 loading 视图
    /// @TTVideoEngineLoadStatePlayable  隐藏 loading 视图
    /// @TTVideoEngineLoadStateStalled   显示 loading 视图
    NSLog(@"VEVodPlayerAPIExample - loadStateDidChanged to %@", @(loadState));
}

- (void)videoEnginePrepared:(TTVideoEngine *)videoEngine {
    // 播放器各个模块完成初始化，即将开始播放。
    NSLog(@"VEVodPlayerAPIExample - videoEnginePrepared");
}

- (void)videoEngineReadyToDisPlay:(TTVideoEngine *)videoEngine {
    // 显示视频的首帧，可以根据该回调隐藏封面图，显示视频画面
    NSLog(@"VEVodPlayerAPIExample - videoEngineReadyToDisPlay");
}

- (void)videoEngineReadyToPlay:(TTVideoEngine *)videoEngine {
    // 视频开始播放
    NSLog(@"VEVodPlayerAPIExample - videoEngineReadyToPlay");
}

- (void)videoEngine:(TTVideoEngine *)videoEngine retryForError:(NSError *)error {
    // SDK 内部在重试，error 为内部的错误信息
    NSLog(@"VEVodPlayerAPIExample - videoEngine is retrying and error is %@", error);
}

- (void)videoEngineStalledExcludeSeek:(TTVideoEngine *)videoEngine {
    // 视频发生了卡顿
    NSLog(@"VEVodPlayerAPIExample - videoEngineStalledExcludeSeek");
}

- (void)videoEngine:(TTVideoEngine *)videoEngine mdlKey:(NSString *)key hitCacheSze:(NSInteger)cacheSize {
    // 当前播放命中的缓存信息，key 对应缓存的唯一标识符
    /// 如果视频做了预加载，cacheSize > 0，表示命中了预加载
    NSLog(@"VEVodPlayerAPIExample - mdl key = %@ - hitCacheSize = %ld", key, (long)cacheSize);
}

// 调用了播放器的 stop 方法，执行完毕回调该方法
- (void)videoEngineUserStopped:(TTVideoEngine *)videoEngine {
    NSLog(@"VEVodPlayerAPIExample - videoEngineUserStopped");
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine error:(nullable NSError *)error {
    // 播放结束，error 为空，正常播放结束，error 不为空，播放失败，error 对应具体的错误信息
    if (!error) {
        NSLog(@"VEVodPlayerAPIExample - videoEngineDidFinish");
    }else {
        NSLog(@"VEVodPlayerAPIExample - videoEngineDidFinish but the error is %@", error);
    }
}
  
- (void)videoEngineCloseAysncFinish:(TTVideoEngine *)videoEngine {
    // 调用 closeAysnc , 执行完毕回调该方法
    NSLog(@"VEVodPlayerAPIExample - videoEngineCloseAysncFinish");
}

#pragma mark - TTVideoEnginePreloadDelegate

- (void)localServerTestSpeedInfo:(NSTimeInterval)timeInternalMs size:(NSInteger)sizeByte {
    // 间隔时间，单位秒
    NSTimeInterval time = timeInternalMs / 1000;
    // 间隔时间内下载数据大小，单位 KB
    CGFloat dataSize = sizeByte / 1024;
    // 当前视频下载速度
    CGFloat downloadSpeed = dataSize / time;
    NSLog(@"VEVodPlayerAPIExample - localServerTestSpeedInfo callback, timeInternalMs: %@, size: %@, speed: %.1f KB/s", @(timeInternalMs), @(sizeByte), downloadSpeed);
}

#pragma mark - UI

- (UISlider *)progressSliderForPlay {
    if (_progressSliderForPlay == NULL) {
        _progressSliderForPlay = [[UISlider alloc] init];
        _progressSliderForPlay.minimumTrackTintColor = [UIColor blueColor];
        [_progressSliderForPlay addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        _progressSliderForPlay.tag = 0;
    }
    return _progressSliderForPlay;
}

- (UISlider *)progressSliderForCache {
    if (_progressSliderForCache == NULL) {
        _progressSliderForCache = [[UISlider alloc] init];
        _progressSliderForCache.minimumTrackTintColor = [UIColor blueColor];
        _progressSliderForCache.tag = 1;
    }
    return _progressSliderForCache;
}

- (UISlider *)progressSliderForSound {
    if (_progressSliderForSound == NULL) {
        _progressSliderForSound = [[UISlider alloc] init];
        _progressSliderForSound.minimumTrackTintColor = [UIColor blueColor];
        [_progressSliderForSound addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        _progressSliderForSound.tag = 2;
        _progressSliderForSound.maximumValue = 1.0;
        
    }
    return _progressSliderForSound;
}

- (UILabel *)playLabel {
    if (_playLabel == NULL) {
        _playLabel = [[UILabel alloc] init];
    }
    return _playLabel;
}

- (UILabel *)cacheLabel {
    if (_cacheLabel == NULL) {
        _cacheLabel = [[UILabel alloc] init];
    }
    return _cacheLabel;
}

@end
