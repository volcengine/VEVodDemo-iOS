//
//  ExampleAdLabelModule.m
//  VESceneModule
//
//  Created by litao.he on 2024/11/11.
//

#import "ExampleAdLabelModule.h"
#import "VEPlayerContext.h"
#import "VEPlayerActionViewInterface.h"
#import <Masonry/Masonry.h>
#import "UIColor+Hex.h"

@interface ExampleAdLabelModule ()

@property (nonatomic, strong) UIImageView *image;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@end

@implementation ExampleAdLabelModule

VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configuratoinCustomView];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.underlayControlView addSubview:self.image];

    [self.image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.actionViewInterface.underlayControlView).with.offset(55);
        make.right.equalTo(self.actionViewInterface.underlayControlView).with.offset(-10);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.image) {
        [self.image removeFromSuperview];
        self.image = nil;
    }
}

#pragma mark - Setter & Getter

- (UIView *)image {
    if (_image == nil) {
        UIImage *image = [UIImage imageNamed:@"ad_image"];
        if (image) {
            _image = [[UIImageView alloc] initWithImage:image];
            _image.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        }
    }
    return _image;
}

@end
