//
//  ShortDramaPlayControlViewController.m
//  JSONModel
//

#import "ShortDramaPlayControlViewController.h"
#import "VEShortDramaDetailFeedViewController.h"
#import "VEVideoPlayerController.h"
#import "ShortDramaCollectViewController.h"
#import "ShortDramaPraiseViewController.h"
#import "ShortDramaIntroduceView.h"
#import "ShortDramaSeriesView.h"
#import "VEShortVideoProgressSlider.h"
#import "ShortDramaVideoPlayView.h"
#import "ShortDramaVideoProgressView.h"
#import <Masonry/Masonry.h>
#import "VEDramaVideoInfoModel.h"

@interface ShortDramaPlayControlViewController () <ShortDramaSeriesViewDelegate>

@property (nonatomic, weak) VEVideoPlayerController *playerController;
@property (nonatomic, strong) UIImageView *topCoverImageView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) ShortDramaCollectViewController *collectViewController;
@property (nonatomic, strong) ShortDramaPraiseViewController *praiseViewController;
@property (nonatomic, strong) ShortDramaIntroduceView *introView;
@property (nonatomic, strong) ShortDramaSeriesView *seriesView;
@property (nonatomic, strong) VEShortVideoProgressSlider *progressSlider;
@property (nonatomic, strong) ShortDramaVideoPlayView *videoPlayView;
@property (nonatomic, strong) ShortDramaVideoProgressView *videoProgressView;
@property (nonatomic, strong) VEDramaVideoInfoModel *dramaVideoInfoModel;

@end

@implementation ShortDramaPlayControlViewController

- (instancetype)initWithVideoPlayerController:(VEVideoPlayerController *)playerController {
    self = [super init];
    if (self) {
        self.playerController = playerController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
}

#pragma mark - public

- (void)reloadData:(id)dataObj {
    self.dramaVideoInfoModel = (VEDramaVideoInfoModel *)dataObj;
    [self.introView reloadData:dataObj];
    [self.seriesView reloadData:dataObj];
}

- (void)cleanScreen:(BOOL)isClean animate:(BOOL)animate {
    [UIView animateWithDuration:animate ? 0.3 : 0 animations:^{
        self.collectViewController.view.alpha = isClean ? 0 : 1;
        self.praiseViewController.view.alpha = isClean ? 0 : 1;
        self.introView.alpha = isClean ? 0 : 1;
        self.seriesView.alpha = isClean ? 0 : 1;
        self.videoPlayView.alpha = isClean ? 0 : 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)closePlayer {
    [self.progressSlider closePlayer];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    [self.view addSubview:self.topCoverImageView];
    [self.view addSubview:self.coverImageView];
    [self addChildViewController:self.collectViewController];
    [self.view addSubview:self.collectViewController.view];
    [self addChildViewController:self.praiseViewController];
    [self.view addSubview:self.praiseViewController.view];
    [self.view addSubview:self.introView];
    [self.view addSubview:self.seriesView];
    [self.view addSubview:self.progressSlider];
    [self.view addSubview:self.videoPlayView];
    [self.view addSubview:self.videoProgressView];
    
    [self.topCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(UIScreen.mainScreen.bounds.size.width * 280 /375);
    }];
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.mas_equalTo(UIScreen.mainScreen.bounds.size.width * 280 /375);
    }];
    
    [self.seriesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-20);
        make.left.equalTo(self.view).with.offset(12);
        make.right.equalTo(self.view).with.offset(-90);
        make.height.mas_equalTo(ShortDramaSeriesViewHeight);
    }];
    
    [self.introView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.seriesView.mas_top).with.offset(-10);
        make.left.equalTo(self.view).with.offset(12);
        make.right.equalTo(self.view).with.offset(-90);
        make.height.mas_equalTo(ShortDramaIntroduceViewHeight);
    }];
    
    [self.collectViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-20);
        make.right.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ShortDramaCollectViewControllerWdithHeight, ShortDramaCollectViewControllerWdithHeight));
    }];
    
    [self.praiseViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.collectViewController.view.mas_top).with.offset(-12);
        make.right.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ShortDramaPraiseViewControllerWdithHeight, ShortDramaPraiseViewControllerWdithHeight));
    }];
    
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.mas_equalTo(20);
    }];
    
    [self.videoPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
    [self.videoProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.progressSlider.mas_top).with.offset(-100);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(ShortDramaVideoProgressViewHeight);
    }];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickPlayControlViewHandle:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - ShortDramaSeriesViewDelegate

- (void)onClickDramaCallback {
    [self.playerController pause];
    self.dramaVideoInfoModel.startTime = self.playerController.currentPlaybackTime;
    VEShortDramaDetailFeedViewController *detailFeedViewController = [[VEShortDramaDetailFeedViewController alloc] initWtihDramaVideoInfo:self.dramaVideoInfoModel];
    UINavigationController *navigationController = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [navigationController pushViewController:detailFeedViewController animated:YES];
}

#pragma mark - GestureRecognizer

- (void)onClickPlayControlViewHandle:(UIGestureRecognizer *)gesRecognizer {
    if ([self.playerController isPlaying]) {
        [self.playerController pause];
        self.videoPlayView.hidden = NO;
    } else {
        self.videoPlayView.hidden = YES;
        if (self.playerController.playbackState == VEVideoPlaybackStateFinished) {
            self.playerController.startTime = 0;
        }
        [self.playerController play];
    }
}

#pragma mark - lazy load

- (UIImageView *)topCoverImageView {
    if (_topCoverImageView == nil) {
        _topCoverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_feed_cover"]];
        _topCoverImageView.transform = CGAffineTransformMakeRotation(M_PI);
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
    }
    return _topCoverImageView;
}

- (UIImageView *)coverImageView {
    if (_coverImageView == nil) {
        _coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_feed_cover"]];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
    }
    return _coverImageView;
}

- (ShortDramaCollectViewController *)collectViewController {
    if (_collectViewController == nil) {
        _collectViewController = [[ShortDramaCollectViewController alloc] init];
    }
    return _collectViewController;
}

- (ShortDramaPraiseViewController *)praiseViewController {
    if (_praiseViewController == nil) {
        _praiseViewController = [[ShortDramaPraiseViewController alloc] init];
    }
    return _praiseViewController;
}

- (ShortDramaIntroduceView *)introView {
    if (_introView == nil) {
        _introView = [[ShortDramaIntroduceView alloc] init];
    }
    return _introView;
}

- (ShortDramaSeriesView *)seriesView {
    if (_seriesView == nil) {
        _seriesView = [[ShortDramaSeriesView alloc] init];
        _seriesView.delegate = self;
    }
    return _seriesView;
}

- (VEShortVideoProgressSlider *)progressSlider {
    if (_progressSlider == nil) {
        _progressSlider = [[VEShortVideoProgressSlider alloc] initWithContentMode:VEProgressSliderContentModeBottom];
        _progressSlider.progressBackgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        _progressSlider.progressColor = [UIColor whiteColor];
        _progressSlider.progressBufferColor = [UIColor clearColor];
        _progressSlider.thumbHeight = 4;
        _progressSlider.thumbOffset = 12;
        _progressSlider.delegate = self.videoProgressView;
        _progressSlider.player = self.playerController;
    }
    return _progressSlider;
}

- (ShortDramaVideoPlayView *)videoPlayView {
    if (_videoPlayView == nil) {
        _videoPlayView = [[ShortDramaVideoPlayView alloc] init];
        _videoPlayView.hidden = YES;
    }
    return _videoPlayView;
}

- (ShortDramaVideoProgressView *)videoProgressView {
    if (_videoProgressView == nil) {
        _videoProgressView = [[ShortDramaVideoProgressView alloc] init];
        _videoProgressView.playControlDelegate = self;
    }
    return _videoProgressView;
}

@end
