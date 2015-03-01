//
//  LevelSelectView.m
//  Amaze Ball
//
//  Created by John Karabinos on 1/26/15.
//  Copyright (c) 2015 John Karabinos. All rights reserved.
//

#import "LevelSelectView.h"
#import "BRLevelSelectViewController.h"

@implementation LevelSelectView




+ (id)lsv
{
    LevelSelectView *lsv = [[[NSBundle mainBundle] loadNibNamed:@"LevelSelectView" owner:nil options:nil] lastObject];
    //UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectLevel:)];
    //[lsv addGestureRecognizer:tap];
    
    
    // make sure customView is not nil or the wrong class!
    if ([lsv isKindOfClass:[LevelSelectView class]])
        return lsv;
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

- (IBAction)selectLevel:(id)sender {
    NSLog(@"select");
     [self.parentViewController loadLevel:self];
}
@end
