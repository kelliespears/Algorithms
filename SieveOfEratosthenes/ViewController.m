//
//  ViewController.m
//  SieveOfEratosthenes
//
//  Created by Kellie Spears on 11/17/16.
//  Copyright © 2016 Kellie Spears. All rights reserved.
//

#import "ViewController.h"

// Collaborator
#import "ViewControllerModel.h"

NSInteger const LIMIT_MAX = 1000000;
NSString *const CELL_IDENTIFIER = @"collectionCell";
NSString *const FIND_BUTTON = @"FIND";
NSString *const LIMIT_PLACEHOLDER = @"NUMBER (BETWEEN 1-1000000)";
NSString *const TITLE_LABEL = @"Prime Time";
NSString *const TOTAL = @"Total Primes";
NSString *const kCalculate = @"Calculate";
NSString *const kResults = @"Results";

@interface ViewController ()

@property (nonatomic, strong) NSArray<NSNumber *>*primes;
@property (nonatomic, strong) CALayer *layer;

@end

@implementation ViewController

-(ViewControllerModel *)model {

    if(!_model)
        _model = [[ViewControllerModel alloc] init];

    return _model;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // setup model
    [self bindToModel];

    // setup label
    self.titleLabel.text = TITLE_LABEL;

    // setup button
    [self.findButton setTitle:FIND_BUTTON forState:UIControlStateNormal];
    self.findButton.enabled = NO;

    // setup keyboard
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];

    UIBarButtonItem *flexBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    keyboardToolbar.items = @[flexBarButtonItem, doneBarButtonItem];

    // setup text field
    self.limitTextField.delegate = self;
    self.limitTextField.placeholder = LIMIT_PLACEHOLDER;
    self.limitTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.limitTextField.inputAccessoryView = keyboardToolbar;

    // setup table view
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    // setup animation
    self.layer = [[CALayer alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.primes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)];
    label.text = [self.primes[indexPath.row] stringValue];
    label.minimumScaleFactor = 7/[UIFont systemFontSize];
    label.adjustsFontSizeToFitWidth = YES;
    label.layer.borderColor = [UIColor whiteColor].CGColor;
    label.layer.borderWidth = 0;
    label.layer.cornerRadius = label.bounds.size.height/ 2;
    label.layer.masksToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.highlightedTextColor = [UIColor redColor];
    label.textColor = [UIColor blueColor];
    label.backgroundColor = [UIColor greenColor];

    [cell.contentView addSubview:label];

    return cell;
}

#pragma mark - animation
-(void)calculateAnimation {

    CAReplicatorLayer *replicator = [[CAReplicatorLayer alloc] init];
    replicator.bounds = CGRectMake(0, 0, 60, 60);
    CGFloat adjustedHeight = replicator.bounds.size.height/2;
    CGFloat adjustedWidth = self.limitTextField.frame.size.width + 35.f;
    CGPoint endPoint = CGPointMake(self.limitTextField.frame.origin.x + adjustedWidth, self.limitTextField.frame.origin.y - adjustedHeight);
    CGPoint rPoint = [self.limitTextField.superview convertPoint:endPoint toView:self.view];
    replicator.position = CGPointMake(rPoint.x, rPoint.y + 35.f);
    [self.view.layer addSublayer:replicator];

    self.layer.bounds = CGRectMake(0, 0, 8, 40);
    self.layer.position = CGPointMake(10, 75);
    self.layer.cornerRadius = 2;
    self.layer.backgroundColor = [UIColor redColor].CGColor;
    [replicator addSublayer:self.layer];

    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.y"];
    move.toValue = @(self.layer.position.y - 35);
    move.duration = 0.5;
    move.autoreverses = YES;
    move.repeatCount = INFINITY;
    [self.layer addAnimation:move forKey:kCalculate];

    replicator.instanceCount = 3;
    replicator.instanceTransform = CATransform3DMakeTranslation(20, 0, 0);
    replicator.instanceDelay = 0.33;
    replicator.masksToBounds = YES;
}

-(void)resultsAnimation {

    CABasicAnimation *move = [[CABasicAnimation alloc] init];
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{

            UILabel *label = [[UILabel alloc] init];
            CGRect rect = self.collectionView.frame;
            CGFloat adjustedWidth = rect.size.width/3;
            label.bounds = CGRectMake(rect.origin.x + adjustedWidth, rect.origin.x + adjustedWidth, adjustedWidth, adjustedWidth);
            label.text = [NSString stringWithFormat:@" %@ \r%@", TOTAL,@(self.primes.count)];
            label.numberOfLines = 0;
            label.minimumScaleFactor = 6/[UIFont systemFontSize];
            label.adjustsFontSizeToFitWidth = YES;
            label.textAlignment = NSTextAlignmentCenter;
            label.highlightedTextColor = [UIColor redColor];
            label.textColor = [UIColor blueColor];
            label.backgroundColor = [UIColor yellowColor];
            label.layer.borderColor = [UIColor redColor].CGColor;
            label.layer.borderWidth = 3;
            label.layer.cornerRadius = adjustedWidth/2;
            label.layer.masksToBounds = YES;
            [self.view.layer addSublayer:label.layer];

            [UIView animateWithDuration:4 delay:0.f options:UIViewAnimationOptionTransitionNone animations:^{

                // remove previous animation
                [self.layer removeFromSuperlayer];

                // show disabled findButton
                self.findButton.hidden = NO;
                self.findButton.enabled = NO;

                // load primes
                [self.collectionView reloadData];

                label.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height + 100);

            } completion:^(BOOL finished) {

                // enable findButton
                self.findButton.enabled = YES;

                // remove current animation
                [label removeFromSuperview];
            }];
        }];
        [self.layer addAnimation:move forKey:kResults];
        [CATransaction commit];
    }
}

#pragma mark - UITextFieldDelegate methods
// Dismisses keyboard when touching outside the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

// Called when the text field becomes active
- (void)textFieldDidBeginEditing:(UITextField *)textField {

    // disable findButton
    self.findButton.enabled = NO;
}

// Called when the text field becomes inactive
- (void)textFieldDidEndEditing:(UITextField *)textField {

    if((NSInteger)self.limitTextField.text.length > 0) self.findButton.enabled = YES;
}

/* Called each time the user types a character on the keyboard;
 * called just before a character is displayed
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    return [self validateLimit:textField.text range:range replacement:string];
}

// Called when the user presses the clear button
- (BOOL)textFieldShouldClear:(UITextField *)textField {

    //clear grid
    self.primes = nil;
    [self.collectionView reloadData];

    return YES;
}

// Called when the user presses the return key on the keyboard
 - (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];

    return YES;
}

// Called when phone keyboard is invoked from textfield
- (void)done {

    // close keyboard
    [self.limitTextField resignFirstResponder];

    // (possibly) enable findButton
    if((NSInteger)self.limitTextField.text.length > 0) self.findButton.enabled = YES;
}

#pragma mark - action methods
- (IBAction)findPrimes:(UIButton *)sender {

    // close keyboard (if necessary)
    if([self.limitTextField isFirstResponder]) [self.limitTextField resignFirstResponder];

    // hide findButton
    self.findButton.hidden = YES;

    // clear grid
    self.primes = nil;
    [self.collectionView reloadData];

    // set animation
    [self calculateAnimation];

    // model call
    [self.model retrievePrimes:[self.limitTextField.text integerValue]];
}

-( BOOL)validateLimit:(NSString *)textfield range:(NSRange)range replacement:(NSString *)string {

    // empty string is not valid
    if (!string.length && range.length <= 0) return NO;

    // remove leading zero(s)
    if ([string hasPrefix:@"0"] && !textfield.length) return NO;

    NSCharacterSet *keepSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSCharacterSet *removeSet = [keepSet invertedSet];
    NSRange removeRange = [string rangeOfCharacterFromSet:removeSet options:NSCaseInsensitiveSearch];

    // string is not a valid number
    if (removeRange.location != NSNotFound) return NO;

    // no complaints, string is valid number
    return [[textfield stringByAppendingString:string] integerValue] <= LIMIT_MAX;
}

-(void)bindToModel {
    self.model.didGetPrimesData = [self modelDidGetPrimesData];
}

-(didGetPrimesDataBlock)modelDidGetPrimesData {
    return ^(NSArray<NSNumber *>*primes) {

        // set animation
        [self resultsAnimation];

        // setup primes
        self.primes = [primes copy];
    };
}

@end
