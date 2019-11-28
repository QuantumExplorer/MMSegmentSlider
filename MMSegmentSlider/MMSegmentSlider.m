#import "MMSegmentSlider.h"

static CGFloat const HorizontalInsets = 45.0f;
static CGFloat const BottomOffset = 15.0f;

@interface MMSegmentSlider ()

@property (nonatomic, strong) CAShapeLayer *sliderLayer;
@property (nonatomic, strong) CAShapeLayer *stopsLayer;
@property (nonatomic, strong) CAShapeLayer *selectedLayer;
@property (nonatomic, strong) CAShapeLayer *labelsLayer;
@property (nonatomic, assign) NSUInteger fontSizeReduction;

@end

@implementation MMSegmentSlider

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupProperties];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupProperties];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupProperties];
    }
    
    return self;
    
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupLayers];
}

- (void)prepareForInterfaceBuilder
{
    [self setupLayers];
}

- (void)layoutSubviews
{
    [self updateLayers];
    [self setNeedsDisplay];
}

- (void)setupProperties
{
    _basicColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    _selectedValueColor = [UIColor blackColor];
    _selectedLabelColor = [UIColor blackColor];
    _labelColor = [UIColor grayColor];
    
    _textOffset = 30.0f;
    _stopItemHeight = 12.0f;
    _circlesRadiusForSelected = 26.0f;
    
    _selectedItemIndex = 0;
    _shrinkFontToFitBounds = YES;
    _values = @[@0, @1, @2];
    _labels = @[@"item 0", @"item 1", @"item 2"];
    _fontSizeReduction = 0;
    
    _labelsFont = [UIFont fontWithName:@"Helvetica-Light" size:16.0f];
}

#pragma mark - Shape Layers

- (void)setupLayers
{
    self.sliderLayer = [CAShapeLayer layer];
    self.sliderLayer.lineWidth = 3.0f;
    [self.layer addSublayer:self.sliderLayer];
    
    self.stopsLayer = [CAShapeLayer layer];
    [self.layer addSublayer:self.stopsLayer];
    
    self.selectedLayer = [CAShapeLayer layer];
    [self.layer addSublayer:self.selectedLayer];
}

- (void)updateLayers
{
    self.sliderLayer.strokeColor = self.basicColor.CGColor;
    self.sliderLayer.path = [[self pathForSlider] CGPath];
    
    if ([self useCircles]) {
        self.stopsLayer.fillColor = self.basicColor.CGColor;
    } else {
        self.stopsLayer.strokeColor = self.basicColor.CGColor;
        self.stopsLayer.lineWidth = self.stopItemWidth;
    }
    self.stopsLayer.path = [[self pathForStopItems] CGPath];
    
    self.selectedLayer.fillColor = self.selectedValueColor.CGColor;
    self.selectedLayer.path = [[self pathForSelected] CGPath];
}

- (void)animateSelectionChange
{
    CGPathRef oldPath = self.selectedLayer.path;
    CGPathRef newPath = [[self pathForSelected] CGPath];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (__bridge id) oldPath;
    pathAnimation.toValue = (__bridge id) newPath;
    pathAnimation.duration = 0.25f;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.20 :1.00 :0.70 :1.00];

    self.selectedLayer.path = newPath;
    [self.selectedLayer addAnimation:pathAnimation forKey:@"PathAnimation"];
}

- (UIBezierPath *)pathForSlider
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat lineY = self.bounds.size.height - self.stopItemHeight - BottomOffset;
    [path moveToPoint:CGPointMake(self.stopItemWidth + HorizontalInsets, lineY)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width - self.stopItemWidth - HorizontalInsets, lineY)];
    [path closePath];
    
    return path;
}

- (UIBezierPath *)pathForStopItems
{
    if ([self useCircles]) {
        return [self pathForStopCircles];
    } else {
        return [self pathForStopLines];
    }
}

- (UIBezierPath *)pathForStopLines
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat startPointX = self.stopItemWidth + HorizontalInsets;
    CGFloat intervalSize = (self.bounds.size.width - (self.stopItemWidth + HorizontalInsets) * 2.0) / (self.values.count - 1);
    CGFloat yPos = self.bounds.size.height - self.stopItemHeight - BottomOffset;
    
    for (int i = 0; i < self.values.count; i++) {
        CGPoint top = CGPointMake(startPointX + i * intervalSize, yPos + self.stopItemHeight/2);
        CGPoint bottom = CGPointMake(startPointX + i * intervalSize, yPos - self.stopItemHeight/2);
        [path moveToPoint:top];
        [path addLineToPoint:bottom];
        [path closePath];
    }
    
    return path;
}

- (UIBezierPath *)pathForStopCircles
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat startPointX = self.stopItemWidth + HorizontalInsets;
    CGFloat intervalSize = (self.bounds.size.width - (self.stopItemWidth + HorizontalInsets) * 2.0) / (self.values.count - 1);
    CGFloat yPos = self.bounds.size.height - self.stopItemHeight - BottomOffset;
    
    for (int i = 0; i < self.values.count; i++) {
        CGPoint center = CGPointMake(startPointX + i * intervalSize, yPos);
        CGRect ovalRect = CGRectMake(center.x - self.stopItemWidth/2, center.y - self.stopItemHeight/2, self.stopItemWidth, self.stopItemHeight);
        [path appendPath:[UIBezierPath bezierPathWithOvalInRect:ovalRect]];
    }
    
    return path;
}

- (UIBezierPath *)pathForSelected
{
    UIBezierPath *path = [UIBezierPath bezierPath];

    CGFloat startPointX = self.bounds.origin.x + self.stopItemWidth + HorizontalInsets;
    CGFloat intervalSize = (self.bounds.size.width - (self.stopItemWidth + HorizontalInsets) * 2.0) / (self.values.count - 1);
    CGFloat yPos = self.bounds.origin.y + self.bounds.size.height - self.stopItemHeight - BottomOffset;
    CGPoint center = CGPointMake(startPointX + self.selectedItemIndex * intervalSize, yPos);

    [path addArcWithCenter:center
                    radius:self.circlesRadiusForSelected
                startAngle:0
                  endAngle:2 * M_PI
                 clockwise:YES];
    [path closePath];

    return path;
}

#pragma mark - UIView drawing

- (void)drawRect:(CGRect)rect
{
    [self drawLabels];
}

- (void)drawLabels
{
    CGFloat startPointX = self.bounds.origin.x + self.stopItemWidth + HorizontalInsets;
    CGFloat intervalSize = (self.bounds.size.width - (self.stopItemWidth + HorizontalInsets) * 2.0) / (self.values.count - 1);
    
    CGFloat yPos = self.bounds.origin.y + self.bounds.size.height + 5 - self.circlesRadiusForSelected - BottomOffset * 2;
    
    NSMutableArray * boundsArray = [NSMutableArray array];
    NSMutableArray * correctedBoundsArray = [NSMutableArray array];
    NSMutableArray * attributedStringArray = [NSMutableArray array];
    
    NSUInteger totalNeededBounds = 0;
    NSUInteger startX = 0;
    NSUInteger endX = 0;
    
    for (int i = 0; i < self.values.count; i++) {
        if (_hideInnerLabels && (i!=0) && (i!=self.values.count -1)) continue;
        UIColor *textColor = self.selectedItemIndex == i ? self.selectedLabelColor : self.labelColor;
        BOOL onRightEdgeWithHiddenInnerLabels = _hideInnerLabels && i && (self.labels.count == 2);
        BOOL onRightEdge = (i == self.values.count -1);
        BOOL onLeftEdge = (i == 0);
        NSTextAlignment alignment = NSTextAlignmentCenter;
        if (self.frameLabelsToSlider) {
            if (onRightEdge) {
                alignment = NSTextAlignmentRight;
            } else if (onLeftEdge) {
                alignment = NSTextAlignmentLeft;
            }
        }
        NSAttributedString * attributedString = nil;
        if (self.attributedLabels.count) {
            NSMutableAttributedString * mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[self.attributedLabels objectAtIndex:onRightEdgeWithHiddenInnerLabels?1:i]];
            
            [mutableAttributedString beginEditing];

            [mutableAttributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {

                UIFont* oldFont = value;
                UIFont* font = [oldFont fontWithSize:oldFont.pointSize - self.fontSizeReduction];

                [mutableAttributedString removeAttribute:NSFontAttributeName range:range];
                [mutableAttributedString addAttribute:NSFontAttributeName value:font range:range];
            }];

            [mutableAttributedString endEditing];
            attributedString = [mutableAttributedString copy];
        } else {
            NSString * string = [self.labels objectAtIndex:onRightEdgeWithHiddenInnerLabels?1:i];
            NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            textStyle.alignment = alignment;
            UIFont * font = [self.labelsFont fontWithSize:self.labelsFont.pointSize - self.fontSizeReduction];
            attributedString = [[NSAttributedString alloc] initWithString:string attributes:@{
                                    NSFontAttributeName: font,
                                    NSForegroundColorAttributeName: self.labelColor,
                                    NSParagraphStyleAttributeName: textStyle
            }];
        }
        CGRect bounds = [self boundingRectForAttributedLabel:attributedString
          atPoint:CGPointMake(startPointX + i * intervalSize, yPos - self.textOffset)
        withColor:textColor withAlignment:alignment];
        [boundsArray addObject:[NSValue valueWithCGRect:bounds]];
        [attributedStringArray addObject:attributedString];
        totalNeededBounds += bounds.size.width;
        totalNeededBounds += 10;
        if (i == 0) {
            startX = bounds.origin.x;
        }
        if (i == self.values.count - 1) {
            endX = bounds.origin.x + bounds.size.width;
        }
    }
    
    totalNeededBounds -= 10;
    NSUInteger totalUsedBounds = endX - startX;
    
    //make sure bounds don't overlap
    
    if (totalNeededBounds > totalUsedBounds) {
        //we have an overlap we need to fix
        if (self.shrinkFontToFitBounds && totalNeededBounds > self.bounds.size.width && self.fontSizeReduction < 128) {
            self.fontSizeReduction++;
            [self drawLabels];
            return;
        }
        //first calculate extra size needed
        //NSUInteger extraBoundsNeeded = totalNeededBounds - totalUsedBounds;
        NSInteger start = self.bounds.size.width/2 - totalNeededBounds/2;
        for (int i = 0; i<boundsArray.count; i++) {
            CGRect bounds = [[boundsArray objectAtIndex:i] CGRectValue];
            CGRect correctedBounds = CGRectMake(start, bounds.origin.y, bounds.size.width, bounds.size.height);
            [correctedBoundsArray addObject:[NSValue valueWithCGRect:correctedBounds]];
            start += bounds.size.width + 10;
        }
    } else {
        //all is good
        correctedBoundsArray = boundsArray;
    }
    

    
    int i = 0;
    
    for (NSAttributedString * attributedString in attributedStringArray) {
        CGRect bounds = [[correctedBoundsArray objectAtIndex:i] CGRectValue];
        [attributedString drawInRect:bounds];
        i++;
    }
}

-(CGRect)boundingRectForAttributedLabel:(NSAttributedString*)label atPoint:(CGPoint)point withColor:(UIColor*)color withAlignment:(NSTextAlignment)alignment {
    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.alignment = alignment;
    CGRect boundingRect = [label boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading context:nil];
    CGRect rect;
    static const uint32_t LABEL_MARGIN = 5;
    if (alignment == NSTextAlignmentLeft) {
        rect = CGRectMake(point.x - LABEL_MARGIN - boundingRect.size.width/5, point.y - LABEL_MARGIN - boundingRect.size.height, boundingRect.size.width + LABEL_MARGIN, boundingRect.size.height + LABEL_MARGIN);
    } else if (alignment == NSTextAlignmentRight) {
        rect = CGRectMake(point.x - 4*boundingRect.size.width/5 - LABEL_MARGIN, point.y - LABEL_MARGIN - boundingRect.size.height, boundingRect.size.width + LABEL_MARGIN, boundingRect.size.height + LABEL_MARGIN);
    } else {
        rect = CGRectMake(point.x - boundingRect.size.width/2, point.y - LABEL_MARGIN - boundingRect.size.height, boundingRect.size.width + LABEL_MARGIN, boundingRect.size.height + LABEL_MARGIN);
    }
    return rect;
}

#pragma mark - Touch handlers

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (touches.count > 1) return;
    
    UITouch *touch = [touches.allObjects firstObject];
    [self switchSelectionForTouch:touch];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (touches.count > 1) return;
    
    UITouch *touch = [touches.allObjects firstObject];
    [self switchSelectionForTouch:touch];
}

- (void)switchSelectionForTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self];
    
    NSInteger index = [self indexForTouchPoint:location];
    BOOL canSwitch = index >= 0 && index < self.values.count && index != self.selectedItemIndex;

    if (canSwitch) {
        [self setSelectedItemIndex:index animated:YES];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (NSInteger)indexForTouchPoint:(CGPoint)point
{
    CGFloat startPointX = self.bounds.origin.x + self.stopItemHeight + HorizontalInsets;
    CGFloat intervalSize = (self.bounds.size.width - (self.stopItemHeight + HorizontalInsets) * 2.0) / (self.values.count - 1);
    CGFloat yPos = self.bounds.origin.y + self.bounds.size.height - self.stopItemHeight - BottomOffset;
    
    NSInteger approximateIndex = round((point.x - startPointX) / intervalSize);
    CGFloat xAccuracy = fabs(point.x - (startPointX + approximateIndex * intervalSize));
    CGFloat yAccuracy = fabs(yPos - point.y);
    
    if (xAccuracy > self.stopItemHeight * 2.4f || yAccuracy > self.bounds.size.height * 0.8f) {
        return -1;
    }
    
    return approximateIndex;
}

#pragma mark - Properties

- (void)setValues:(NSArray *)values
{
    _values = values;
    self.selectedItemIndex = 0;

    [self setNeedsDisplay];
    [self setNeedsLayout];
}

-(void)setLabelsFont:(UIFont *)labelsFont {
    _labelsFont = labelsFont;
    _fontSizeReduction = 0;
}

-(void)setAttributedLabels:(NSArray<NSAttributedString *> *)attributedLabels {
    _attributedLabels = attributedLabels;
    _fontSizeReduction = 0;
}

-(void)setLabels:(NSArray<NSString *> *)labels {
    _labels = labels;
    _fontSizeReduction = 0;
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex
{
    _selectedItemIndex = selectedItemIndex;
    
    [self updateLayers];
    [self setNeedsDisplay];
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex animated:(BOOL)animated
{
    _selectedItemIndex = selectedItemIndex;
    
    if (animated) {
        [self animateSelectionChange];
    }
    else {
        [self updateLayers];
    }
    
    [self setNeedsDisplay];
}

- (id<NSCopying>)currentValue
{
    return [self.values objectAtIndex:self.selectedItemIndex];
}

#pragma mark - UIAccessibility

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    if (_selectedItemIndex < self.labels.count) {
        return self.labels[_selectedItemIndex];
    }
    else {
        return nil;
    }
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitSelected | UIAccessibilityTraitAdjustable | UIAccessibilityTraitSummaryElement;
}

- (void)accessibilityIncrement
{
    if (_selectedItemIndex < self.labels.count - 1) {
        [self setSelectedItemIndex:_selectedItemIndex+1 animated:YES];
    }
}

- (void)accessibilityDecrement
{
    if (_selectedItemIndex > 0) {
        [self setSelectedItemIndex:_selectedItemIndex-1 animated:YES];
    }
}

@end
