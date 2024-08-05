//
//  VESettingCell.m
//  VOLCDemo
//
//  Created by real on 2022/8/29.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VESettingCell.h"

@implementation VESettingCell

- (void)setShowTopLine:(BOOL)showTopLine {
    _showTopLine = showTopLine;
    UIView *topLine = [self valueForKeyPath:@"topSepLine"];
    if ([topLine isKindOfClass:[UIView class]]) {
        topLine.hidden = !showTopLine;
    }
}

@end
