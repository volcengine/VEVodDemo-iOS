//
//  VESelectionBarView.m
//  VOLCDemo
//

#import "VESelectionBarView.h"
#import <Masonry/Masonry.h>

static const NSUInteger VESelectionBarViewTagOffset = 1024;

@interface VESelectionBarView ()

@property (nonatomic) VESelectionBarViewStyle style;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, copy) NSArray<UIView *> *itemContainerViews;
@property (nonatomic, copy) NSArray<UIButton *> *buttons;
@property (nonatomic, strong) UIView *selectedLine;
@property (nonatomic, copy) NSDictionary *titleAttributes;
@property (nonatomic, copy) NSDictionary *selectedTitleAttributes;

@end

@implementation VESelectionBarView

#pragma mark - Life Cycle

- (instancetype _Nonnull)initWithStyle:(VESelectionBarViewStyle)style
                       titleAttributes:(NSDictionary * _Nullable)titleAttributes
               selectedTitleAttributes:(NSDictionary * _Nullable)selectedTitleAttributes {
    self = [super init];
    if (self) {
        _style = style;
        _titleAttributes = titleAttributes;
        _selectedTitleAttributes = selectedTitleAttributes;
        _selectedLineMargin = 0;
        _itemLeftMargin = 0;
        _itemRightMargin = 0;
        _selectedLineHeight = 2.0f;
        
        [self addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        if (VESelectionBarViewStyleSelectedLine == style) {
            _selectedLineColor = [self selectedColor];
            [self.containerView addSubview:self.selectedLine];
            self.selectedLine.layer.cornerRadius = _selectedLineHeight / 2.0f;
        }
    }
    return self;
}

- (void)updateConstraints {
    if (VESelectionBarViewStyleSelectedLine == self.style) {
        [self layoutSelectedLine];
    }
    [super updateConstraints];
}

#pragma mark - Configure Data

- (void)updateWithTitles:(NSArray<NSString *> * _Nonnull)titles selectedIndex:(NSUInteger)selectedIndex {
    for (UIButton *button in self.buttons) {
        [button removeFromSuperview];
    }
    self.buttons = nil;
    for (UIView *itemContainerView in self.itemContainerViews) {
        [itemContainerView removeFromSuperview];
    }
    self.itemContainerViews = nil;
    if (!titles.count) {
        return;
    }
    
    NSMutableArray<UIButton *> *buttons = [NSMutableArray array];
    NSMutableArray<UIView *> *itemContainerViews = [NSMutableArray array];
    NSUInteger index = 0;
    UIView *lastView = nil;
    for (NSString *title in titles) {
        UIView *itemContainerView = [UIView new];
        [self.containerView addSubview:itemContainerView];
        [itemContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(self.containerView);
            if (lastView) {
                make.left.equalTo(lastView.mas_right);
                make.width.equalTo(lastView);
            }
            else {
                make.left.equalTo(self.containerView);
            }
        }];
        lastView = itemContainerView;
        [itemContainerViews addObject:itemContainerView];
        
        UIButton *button = [self buttonWithTitle:title tag:VESelectionBarViewTagOffset + index++];
        [self.containerView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(self.containerView);
            make.left.equalTo(itemContainerView).with.offset(self.itemLeftMargin);
            make.right.equalTo(itemContainerView).with.offset(-self.itemRightMargin);
        }];
        [buttons addObject:button];
    }
    [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView);
    }];
    
    self.buttons = [buttons copy];
    self.itemContainerViews = [itemContainerViews copy];
    
    if (selectedIndex < self.buttons.count) {
        UIButton *button = self.buttons[selectedIndex];
        [self configureButton:button selected:YES];
        [self setNeedsUpdateConstraints];
    }
}

- (void)updateWithTitles:(NSArray<NSString *> * _Nonnull)titles {
    [self updateWithTitles:titles selectedIndex:0];
}

#pragma mark - Event Response

- (void)titleButtonIsSelected:(UIButton *)sender {
    if (![self.buttons containsObject:sender]) {
        return;
    }
    
    for (UIButton *button in self.buttons) {
        [self configureButton:button selected:button.tag == sender.tag];
    }
    
    if (VESelectionBarViewStyleSelectedLine == self.style) {
        [self toggleAnimation];
    }
    !self.selectionCallback ?: self.selectionCallback(self, sender.tag - VESelectionBarViewTagOffset);
}

#pragma mark - Private

- (void)configureButton:(UIButton *)button selected:(BOOL)selected {
    button.selected = selected;
    button.titleLabel.font = selected?[self selectedFont]:[self normalFont];
}

- (void)layoutSelectedLine {
    NSUInteger selectedIndex = self.selectedIndex;
    if (selectedIndex < self.buttons.count) {
        UIButton *selectedButton = self.buttons[selectedIndex];
        [self.selectedLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.containerView).with.offset(self.selectedLineMargin);
            make.height.mas_equalTo(self.selectedLineHeight);
            make.centerX.equalTo(selectedButton);
            if (self.selectedLineWidth > 0.1f) {
                make.width.mas_equalTo(self.selectedLineWidth);
            }
            else {
                make.width.equalTo(selectedButton);
            }
        }];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    if (self.selectedIndex != selectedIndex) {
        for (UIButton *button in self.buttons) {
            [self configureButton:button selected:(button.tag - VESelectionBarViewTagOffset == selectedIndex)];
        }
        if (VESelectionBarViewStyleSelectedLine == self.style) {
            if (animated) {
                [self toggleAnimation];
            }
            else {
                [self layoutSelectedLine];
            }
        }
    }
}

- (UIButton *)buttonWithTitle:(NSString *)title tag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    button.titleLabel.font = [self normalFont];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[self normalColor] forState:UIControlStateNormal];
    [button setTitleColor:[self selectedColor] forState:UIControlStateSelected];
    button.tag = tag;
    [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [button addTarget:self action:@selector(titleButtonIsSelected:)
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)toggleAnimation {
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:[CATransaction animationDuration] animations:^{
         [self layoutIfNeeded];
    }];
}

- (UIColor *)normalColor {
    UIColor *normalColor = self.titleAttributes[NSForegroundColorAttributeName];
    return normalColor ? normalColor : [UIColor blackColor];
}

- (UIColor *)selectedColor {
    UIColor *selectedColor = self.selectedTitleAttributes[NSForegroundColorAttributeName];
    return selectedColor ? selectedColor : [UIColor orangeColor];
}

- (UIFont *)normalFont {
    UIFont *normalFont = self.titleAttributes[NSFontAttributeName];
    return normalFont ? normalFont : [UIFont systemFontOfSize:16];
}

- (UIFont *)selectedFont {
    UIFont *selectedFont = self.selectedTitleAttributes[NSFontAttributeName];
    return selectedFont ? selectedFont : [UIFont systemFontOfSize:16];
}

#pragma mark - Getters & Setters

- (UIView *)containerView {
    if (_containerView) {
        return _containerView;
    }
    
    _containerView = [UIView new];
    return _containerView;
}

- (UIView *)selectedLine {
    if (_selectedLine) {
        return _selectedLine;
    }
    
    _selectedLine = [UIView new];
    _selectedLine.backgroundColor = self.selectedLineColor;
    _selectedLine.layer.masksToBounds = YES;
    return _selectedLine;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(contentInset);
    }];
}

- (NSUInteger)selectedIndex {
    for (UIButton *button in self.buttons) {
        if (button.selected) {
            return button.tag - VESelectionBarViewTagOffset;
        }
    }
    
    return NSNotFound;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:YES];
}

- (void)setSelectedLineHeight:(CGFloat)selectedLineHeight {
    _selectedLineHeight = selectedLineHeight;
    
    self.selectedLine.layer.cornerRadius = _selectedLineHeight / 2.0f;
}

- (void)setSelectedLineColor:(UIColor *)selectedLineColor {
    _selectedLineColor = selectedLineColor;
    self.selectedLine.backgroundColor = selectedLineColor;
}

@end
