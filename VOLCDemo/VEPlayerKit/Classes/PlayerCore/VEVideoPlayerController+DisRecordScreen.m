//
//  VEVideoPlayerController+DisRecordScreen.m
//  VEPlayerKit
//
//  Created by zyw on 2024/4/18.
//

#import "VEVideoPlayerController+DisRecordScreen.h"
#import <objc/runtime.h>
#import <Masonry/Masonry.h>
#import "UIColor+RGB.h"

@implementation VEVideoPlayerController (DIsRecordScreen)

@dynamic disRecondScreenView;

- (void)registerScreenCapturedDidChangeNotification {
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenCapturedDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onScreenCapturedChange:) name:UIScreenCapturedDidChangeNotification object:nil];
    }
}

- (void)onScreenCapturedChange:(NSNotification *)notification {
    if (@available(iOS 11.0, *)) {
        UIScreen *screen = notification.object;
        if (screen) {
            if ([screen isCaptured]) {
                [self pause];
                [self showRecordScreenView];
            } else {
                [self play];
                [self removeecordScreenView];
            }
        }
    }
}

- (void)showRecordScreenView {
    if (self.disRecondScreenView == nil) {
        self.disRecondScreenView = [[UIView alloc] init];
        self.disRecondScreenView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2f];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.disRecondScreenView];
        [self.disRecondScreenView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo([[UIApplication sharedApplication] keyWindow]);
        }];
        
        UIView *containerView = [[UIView alloc] init];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.cornerRadius = 16;
        containerView.layer.masksToBounds = YES;
        
        [self.disRecondScreenView addSubview:containerView];
        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo([[UIApplication sharedApplication] keyWindow]);
            make.size.mas_equalTo(CGSizeMake(280, 200));
        }];
        
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_dis_record_screen"]];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor colorWithRGB:0x161823 alpha:1];
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.text = @"该视频不支持录屏";
        
        UILabel *subTitleLabel = [[UILabel alloc] init];
        subTitleLabel.numberOfLines = 2;
        subTitleLabel.textAlignment = NSTextAlignmentCenter;
        subTitleLabel.textColor = [UIColor colorWithRGB:0x161823 alpha:.75];
        subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.lineSpacing = 3;
        NSDictionary *contentAttr = @{ NSFontAttributeName            : [UIFont systemFontOfSize:14],
                                       NSForegroundColorAttributeName : [UIColor colorWithRGB:0x161823 alpha:.75],
                                       NSParagraphStyleAttributeName  : style};
        
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"由于版权原因，视频不支持录制，请关闭录屏继续使用，谢谢您的理解。" attributes:contentAttr];
        subTitleLabel.attributedText = attString;
        
        [containerView addSubview:iconImageView];
        [containerView addSubview:titleLabel];
        [containerView addSubview:subTitleLabel];
        
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(containerView);
            make.top.equalTo(containerView).with.offset(25);
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(containerView);
            make.top.equalTo(iconImageView.mas_bottom).with.offset(30);
        }];

        [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(containerView);
            make.top.equalTo(titleLabel.mas_bottom).with.offset(10);
            make.left.equalTo(containerView).with.offset(20);
            make.right.equalTo(containerView).with.offset(-20);
        }];
    }
}

- (void)removeecordScreenView {
    [self.disRecondScreenView removeFromSuperview];
    self.disRecondScreenView = nil;
}

- (void)setDisRecondScreenView:(UIView *)disRecondScreenView {
    objc_setAssociatedObject(self, @selector(disRecondScreenView), disRecondScreenView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)disRecondScreenView {
    return objc_getAssociatedObject(self, @selector(disRecondScreenView));
}

@end
