//
//  BRViewController.h
//  Amaze Ball
//
//  Created by John Karabinos on 1/17/15.
//  Copyright (c) 2015 John Karabinos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TheBall.h"

@interface BRViewController : UIViewController
- (IBAction)swipeRight:(id)sender;
- (IBAction)swipeLeft:(id)sender;
- (IBAction)swipeDown:(id)sender;
- (IBAction)swipeUp:(id)sender;
- (IBAction)backButton:(id)sender;
- (IBAction)restartLevel:(id)sender;
- (IBAction)nextLevel:(id)sender;
- (IBAction)levelSelect:(id)sender;

@property(strong, nonatomic) NSArray* level1;
@property(strong, nonatomic) NSArray* level3;

@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

-(void)nextLevel;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@end
