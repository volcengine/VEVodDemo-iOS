//
//  VEViewController.m
//  VOLCDemo
//
//  Created by real on 2021/5/21.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VEViewController.h"

@implementation VEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
