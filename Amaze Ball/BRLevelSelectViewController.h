//
//  BRLevelSelectViewController.h
//  Amaze Ball
//
//  Created by John Karabinos on 1/24/15.
//  Copyright (c) 2015 John Karabinos. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BRLevelSelectViewController : UIViewController

-(void)loadLevel:(UIView*)sender;

- (IBAction)moveLeft:(id)sender;
- (IBAction)moveRight:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *levelPackImageView;
@property (weak, nonatomic) IBOutlet UIView *levelPackView;

@end
