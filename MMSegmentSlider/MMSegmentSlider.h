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
 *  Basic labels color
 */
@property (nonatomic, strong) IBInspectable UIColor *labelColor;

/**
 * Selected value color
 */
@property (nonatomic, strong) IBInspectable UIColor *selectedValueColor;

/**
 * Color of selected label
 */
@property (nonatomic, strong) IBInspectable UIColor *selectedLabelColor;

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

/**
 * Text offset from the circle
 */
@property (nonatomic) IBInspectable CGFloat textOffset;

/**
 * Font for labels
 */
@property (nonatomic, strong) UIFont *labelsFont;

/**
 * Contains NSNumber values
 */
@property (nonatomic, strong) NSArray<id<NSCopying>> *values;

/**
 * Contains NSString labels
 */
@property (nonatomic, strong) NSArray<NSString*> *labels;

/**
 * Hide text for inner labels
 */
@property (nonatomic) IBInspectable BOOL hideInnerLabels;

/**
 * Hide text for inner labels
 */
@property (nonatomic) IBInspectable BOOL frameLabelsToSlider;

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
