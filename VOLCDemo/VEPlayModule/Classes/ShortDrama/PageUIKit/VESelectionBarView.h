//
//  VESelectionBarView.h
//  VOLCDemo
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VESelectionBarViewStyle) {
    VESelectionBarViewStyleDefault,
    VESelectionBarViewStyleSelectedLine
};

@class VESelectionBarView;

typedef void (^ _Nullable VESelectionBarViewCallback) (VESelectionBarView * _Nonnull selectionBar, NSUInteger index);

@interface VESelectionBarView : UIView

/**
 * @abstract Returns the style of the selection bar. (read-only)
 */
@property (nonatomic, readonly) VESelectionBarViewStyle style;

/**
 * @abstract The title attributes dictionary used for the normal bar items.
 */
@property (nonatomic, readonly, copy, nullable) NSDictionary *titleAttributes;

/**
 * @abstract The title attributes dictionary used for the selected bar items.
 */
@property (nonatomic, readonly, copy, nullable) NSDictionary *selectedTitleAttributes;

/**
 * @abstract The background color used for the lines of the selected bar items.
 */
@property (nonatomic, strong, nullable) UIColor *selectedLineColor;

/**
 * @abstract The distance that the container view is inset from the enclosing selection bar.
 */
@property (nonatomic) UIEdgeInsets contentInset;

/**
 * @abstract The custom margin for the selected line in line-style bar, in points. Defaults to 10.0.
 */
@property (nonatomic) CGFloat selectedLineMargin;

/**
 * @abstract The custom left margin for a bar item, in points. Defaults to 0.0.
 */
@property (nonatomic) CGFloat itemLeftMargin;

/**
 * @abstract The custom right margin for a bar item, in points. Defaults to 0.0.
 */
@property (nonatomic) CGFloat itemRightMargin;

/**
 * @abstract The custom height for the selected line in line-style bar, in points. Defaults to 3.0.
 */
@property (nonatomic) CGFloat selectedLineHeight;

/**
 * @abstract The custom width for the selected line in line-style bar, in points.
 */
@property (nonatomic) CGFloat selectedLineWidth;

/**
 * @abstract The block to execute when the item of a selection bar is selected.
 */
@property (nonatomic, copy, nullable) VESelectionBarViewCallback selectionCallback;

/**
 * @abstract The currently selected index on the selection bar.
 */
@property (nonatomic) NSUInteger selectedIndex;

/**
 * @abstract Initializes and returns a selection bar having the given style, titleAttributes and selectedTitleAttributes.
 *
 * @param style A constant that specifies the style of the selection bar.
 * @param titleAttributes The title attributes dictionary used for the normal bar items.
 * @param selectedTitleAttributes The title attributes dictionary used for the selected bar items.
 */
- (instancetype _Nonnull)initWithStyle:(VESelectionBarViewStyle)style
                       titleAttributes:(NSDictionary * _Nullable)titleAttributes
               selectedTitleAttributes:(NSDictionary * _Nullable)selectedTitleAttributes;

/**
 * @abstract Updates a Selection bar with given titles.
 */
- (void)updateWithTitles:(NSArray<NSString *> * _Nonnull)titles;

/**
 * @abstract Updates a Selection bar with given titles and a given selected index.
 */
- (void)updateWithTitles:(NSArray<NSString *> * _Nonnull)titles selectedIndex:(NSUInteger)selectedIndex;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

@end
