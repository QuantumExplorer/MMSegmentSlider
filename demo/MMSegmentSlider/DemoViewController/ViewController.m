#import "ViewController.h"
#import "MMSegmentSlider.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet MMSegmentSlider *segmentSlider;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.segmentSlider.values = @[@"$19", @"$99", @"$199", @"$299"];
    
    [self.segmentSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self updatePriceLabel];
}

- (void)sliderValueChanged
{
    [self updatePriceLabel];
}

- (void)updatePriceLabel
{
    self.priceLabel.text = (NSString *)self.segmentSlider.currentValue;
}

@end
