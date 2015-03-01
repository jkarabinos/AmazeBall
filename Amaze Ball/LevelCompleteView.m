//
//  LevelCompleteView.m
//  Amaze Ball
//
//  Created by John Karabinos on 1/25/15.
//  Copyright (c) 2015 John Karabinos. All rights reserved.
//

#import "LevelCompleteView.h"
#import "BRViewController.h"

@implementation LevelCompleteView

- (IBAction)nextLevel:(id)sender {
    [self.parentViewController nextLevel];
    
}

- (IBAction)levelSelect:(id)sender {
    [self.parentViewController levelSelect:self];
}

- (IBAction)replayLevel:(id)sender {
}

+ (id)lcv
{
    LevelCompleteView *lcv = [[[NSBundle mainBundle] loadNibNamed:@"LevelCompleteVIew" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([lcv isKindOfClass:[LevelCompleteView class]])
        return lcv;
    else
        return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
