#import "MMSegmentSlider.h"

@interface MMSegmentSlider ()

@property (nonatomic, strong) CAShapeLayer *sliderLayer;
@property (nonatomic, strong) CAShapeLayer *stopsLayer;
@property (nonatomic, strong) CAShapeLayer *selectedLayer;

@end

@implementation MMSegmentSlider

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupProperties];
        [self setupLayers];
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
        [self setupLayers];
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
    [super prepareForInterfaceBuilder];
    [self setupLayers];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateLayers];
}

- (void)setupProperties
{
    _basicColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    _selectedValueColor = [UIColor blackColor];
    
    _stopItemHeight = 12.0f;
    _circlesRadiusForSelected = 26.0f;
    _sliderWidth = 1.0;
    
    _selectedItemIndex = 0;
    _values = @[@0, @1, @2];
}

#pragma mark - Shape Layers

- (void)setupLayers
{
    self.sliderLayer = [CAShapeLayer layer];
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
    self.sliderLayer.lineWidth = self.sliderWidth;
    
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
    
    CGFloat lineY = self.bounds.size.height / 2.0;
    [path moveToPoint:CGPointMake(self.stopItemWidth + self.horizontalInsets, lineY)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width - self.stopItemWidth - self.horizontalInsets, lineY)];
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
    
    CGFloat startPointX = self.stopItemWidth + self.horizontalInsets;
    CGFloat intervalSize = (self.bounds.size.width - (self.stopItemWidth + self.horizontalInsets) * 2.0) / (self.values.count - 1);
    CGFloat yPos = self.bounds.size.height / 2.0;
    
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
    
    CGFloat startPointX = self.stopItemWidth + self.horizontalInsets;
    CGFloat intervalSize = (self.bounds.size.width - (self.stopItemWidth + self.horizontalInsets) * 2.0) / (self.values.count - 1);
    CGFloat yPos = self.bounds.size.height / 2.0;
    
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

    CGFloat startPointX = self.bounds.origin.x + self.stopItemWidth + self.horizontalInsets;
    CGFloat intervalSize = (self.bounds.size.width - (self.stopItemWidth + self.horizontalInsets) * 2.0) / (self.values.count - 1);
    CGFloat yPos = self.bounds.size.height / 2.0;
    CGPoint center = CGPointMake(startPointX + self.selectedItemIndex * intervalSize, yPos);

    [path addArcWithCenter:center
                    radius:self.circlesRadiusForSelected
                startAngle:0
                  endAngle:2 * M_PI
                 clockwise:YES];
    [path closePath];

    return path;
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
    CGFloat startPointX = self.bounds.origin.x + self.stopItemHeight + self.horizontalInsets;
    CGFloat intervalSize = (self.bounds.size.width - (self.stopItemHeight + self.horizontalInsets) * 2.0) / (self.values.count - 1);
    CGFloat yPos = self.bounds.size.height / 2.0;
    
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

    [self setNeedsLayout];
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex
{
    _selectedItemIndex = selectedItemIndex;
    
    [self updateLayers];
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
}

- (id<NSCopying>)currentValue
{
    return [self.values objectAtIndex:self.selectedItemIndex];
}


@end
