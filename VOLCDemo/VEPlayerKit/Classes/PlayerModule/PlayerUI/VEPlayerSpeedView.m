//
//  VEPlayerSpeedView.m
//  VEPlayerKit
//
//  Created by zys on 2025/10/21.
//

#import "VEPlayerSpeedView.h"
#import <Masonry/Masonry.h>
#import "VEPlayerContextKeyDefine.h"

static NSString *VEPlayerSpeedViewCellID = @"VEPlayerSpeedViewCellID";

@interface VEPlayerSpeedView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UITableView *speedTV;

@property (nonatomic, strong) UITableViewCell *selectedCell;

@property (nonatomic, strong) NSArray<NSNumber *> *speedSet;

@end

@implementation VEPlayerSpeedView

- (instancetype)init {
    self = [super init];
    if (self) {
        _speedSet = @[@(0.5), @(1.0), @(1.5), @(2.0), @(3.0)];
        [self configuratoinCustomView];
    }
    return self;
}

- (void)configuratoinCustomView {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self).multipliedBy(0.5);
        make.right.top.bottom.equalTo(self);
    }];
    
    [self.containerView addSubview:self.speedTV];
    [self.speedTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(5);
        make.bottom.equalTo(self.containerView).offset(-5);
        make.left.equalTo(self.containerView).offset(15);
        make.right.equalTo(self.containerView).offset(-15);
    }];
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickView:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
}

#pragma mark - lazy load

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor blackColor];
        _containerView.alpha = 0.8;
    }
    return _containerView;
}

- (UITableView *)speedTV {
    if (!_speedTV) {
        _speedTV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
        _speedTV.dataSource = self;
        _speedTV.delegate = self;
        _speedTV.separatorStyle = UITableViewCellSeparatorStyleNone;
        _speedTV.backgroundColor = [UIColor clearColor];
        _speedTV.allowsSelection = YES;
        _speedTV.userInteractionEnabled = YES;
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [_speedTV selectRowAtIndexPath:firstIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        if ([_speedTV.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [_speedTV.delegate tableView:_speedTV didSelectRowAtIndexPath:firstIndexPath];
        }
    }
    return _speedTV;
}

#pragma mark - event

- (void)onClickView:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    CGFloat viewWidth = self.bounds.size.width;
    if (touchPoint.x < viewWidth / 2.0) {
        [self removeFromSuperview];
        if (self.context != NULL) {
            [self.context post:@(1) forKey:VEPlayerContextKeyViewVisible];
            [self.context post:@(1) forKey:VEPlayerContextKeyGestureEnabled];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.speedSet.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VEPlayerSpeedViewCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VEPlayerSpeedViewCellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = YES;
    }
    
    NSString *speedStr = [NSString stringWithFormat:@"%.1fx", [self.speedSet[indexPath.row] doubleValue]];
    cell.textLabel.text = speedStr;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedCell.backgroundColor = [UIColor clearColor];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.backgroundView.alpha = 0.5;
    self.selectedCell = cell;
    
    if (self.context == NULL) {
        return;
    }
    
    [self.context post:self.speedSet[indexPath.row] forKey:VEPlayerContextKeyPlaybackSpeedChanged];
    [self removeFromSuperview];
    [self.context post:@(1) forKey:VEPlayerContextKeyViewVisible];
    [self.context post:@(1) forKey:VEPlayerContextKeyGestureEnabled];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self.speedTV];
    if (CGRectContainsPoint(self.speedTV.bounds, touchPoint)) {
        return NO;
    }
    return YES;
}

@end
