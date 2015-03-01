//
//  LevelCompleteView.h
//  Amaze Ball
//
//  Created by John Karabinos on 1/25/15.
//  Copyright (c) 2015 John Karabinos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRViewController.h"

@interface LevelCompleteView : UIView
@property (strong, nonatomic) BRViewController* parentViewController;
- (IBAction)nextLevel:(id)sender;
- (IBAction)levelSelect:(id)sender;
- (IBAction)replayLevel:(id)sender;

+(id)lcv;
@end
