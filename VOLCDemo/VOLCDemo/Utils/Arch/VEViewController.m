//
//  VEViewController.m
//  VOLCDemo
//
//  Created by real on 2021/5/21.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VEViewController.h"

@interface VEViewController ()

@end

@implementation VEViewController

- (void)close {
    if (self.navigationController.viewControllers.firstObject == self) {
        [self dismissViewControllerAnimated:YES completion:^{}];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
