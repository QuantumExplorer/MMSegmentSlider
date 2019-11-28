/**
 *  Segmented slider
 */

#import "UIKit/UIKit.h"

IB_DESIGNABLE
@interface MMSegmentSlider : UIControl

/**
 * Basic slider color
 */
@property (nonatomic, strong) IBInspectable UIColor *basicColor;

/**
 * Selected value color
 */
@property (nonatomic, strong) IBInspectable UIColor *selectedValueColor;

/**
 * Use circular stop points
 */
@property (nonatomic) IBInspectable BOOL useCircles;

/**
 * Item radius or height
 */
@property (nonatomic) IBInspectable CGFloat stopItemHeight;

/**
 * Item radius or height
 */
@property (nonatomic) IBInspectable CGFloat stopItemWidth;

/**
 * Circles radius for the selected item.
 */
@property (nonatomic) IBInspectable CGFloat circlesRadiusForSelected;

@property (nonatomic) IBInspectable CGFloat horizontalInsets;
@property (nonatomic) IBInspectable CGFloat sliderWidth;

/**
 * Contains NSNumber values
 */
@property (nonatomic, strong) NSArray<id<NSCopying>> *values;

/**
 * Set/get current selected value
 */
@property (nonatomic, readonly) id<NSCopying> currentValue;

/**
 * Set/get selected item index
 */
@property (nonatomic) NSInteger selectedItemIndex;

/**
 * Set/get selected item index (animated)
 */
- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex animated:(BOOL)animated;

@end
