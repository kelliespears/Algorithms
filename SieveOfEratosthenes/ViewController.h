//
//  ViewController.h
//  SieveOfEratosthenes
//
//  Created by Kellie Spears on 11/17/16.
//  Copyright © 2016 Kellie Spears. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSInteger const LIMIT_MAX;
extern NSString *const LIMIT_LABEL;
extern NSString *const TITLE_LABEL;

@interface ViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *limitLabel;
@property (weak, nonatomic) IBOutlet UITextField *limitTextField;

-(BOOL)validateLimit:(NSString *)textfield range:(NSRange)range replacement:(NSString *)string;

@end

