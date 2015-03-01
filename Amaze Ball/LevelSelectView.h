//
//  LevelSelectView.h
//  Amaze Ball
//
//  Created by John Karabinos on 1/26/15.
//  Copyright (c) 2015 John Karabinos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRLevelSelectViewController.h"

@interface LevelSelectView : UIView

+ (id)lsv;

@property (strong, nonatomic) BRLevelSelectViewController* parentViewController;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

- (IBAction)selectLevel:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@end
