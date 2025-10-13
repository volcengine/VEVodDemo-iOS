//
//  VEPlayerResolutionView.m
//  VEPlayerKit
//
//  Created by zys on 2025/10/21.
//

#import "VEPlayerResolutionView.h"
#import <Masonry/Masonry.h>
#import "VEPlayerContextKeyDefine.h"

static NSString *VEPlayerResolutionViewCellID = @"VEPlayerResolutionViewCellID";

@interface VEPlayerResolutionView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UITableView *resolutionTV;

@property (nonatomic, strong) UITableViewCell *selectedCell;

@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *resolutionSet;

@property (nonatomic, strong) NSString *curResolution;

@end

@implementation VEPlayerResolutionView

- (instancetype)initWithResolutionSet:(NSArray<NSDictionary<NSString *, NSString *> *> *)resolutionSet CurResolution:(NSString *)curResolution {
    self = [super init];
    if (self) {
        _resolutionSet = resolutionSet;
        _curResolution = curResolution;
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
    
    [self.containerView addSubview:self.resolutionTV];
    [self.resolutionTV mas_makeConstraints:^(MASConstraintMaker *make) {
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

- (UITableView *)resolutionTV {
    if (!_resolutionTV) {
        _resolutionTV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
        _resolutionTV.dataSource = self;
        _resolutionTV.delegate = self;
        _resolutionTV.separatorStyle = UITableViewCellSeparatorStyleNone;
        _resolutionTV.backgroundColor = [UIColor clearColor];
        _resolutionTV.allowsSelection = YES;
        _resolutionTV.userInteractionEnabled = YES;
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:[self findIndexForCurResolution] inSection:0];
        [_resolutionTV selectRowAtIndexPath:firstIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        if ([_resolutionTV.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [_resolutionTV.delegate tableView:_resolutionTV didSelectRowAtIndexPath:firstIndexPath];
        }
    }
    return _resolutionTV;
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
    return self.resolutionSet.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VEPlayerResolutionViewCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VEPlayerResolutionViewCellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = YES;
    }
    
    cell.textLabel.text = self.resolutionSet[indexPath.row].allKeys[0];
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
    
    int enumValue = [self.resolutionSet[indexPath.row].allValues.firstObject intValue];
    [self.context post:@(enumValue) forKey:VEPlayerContextKeyResolutionChanged];
    [self removeFromSuperview];
    [self.context post:@(1) forKey:VEPlayerContextKeyViewVisible];
    [self.context post:@(1) forKey:VEPlayerContextKeyGestureEnabled];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self.resolutionTV];
    if (CGRectContainsPoint(self.resolutionTV.bounds, touchPoint)) {
        return NO;
    }
    return YES;
}

#pragma mark - Private

- (NSInteger)findIndexForCurResolution {
    for (NSInteger i = 0; i < self.resolutionSet.count; ++i) {
        if ([self.resolutionSet[i].allKeys[0] isEqualToString:self.curResolution]) {
            return i;
        }
    }
    return -1;
}

@end
