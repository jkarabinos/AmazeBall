//
//  TheBall.m
//  Amaze Ball
//
//  Created by John Karabinos on 1/17/15.
//  Copyright (c) 2015 John Karabinos. All rights reserved.
//

#import "TheBall.h"

@implementation TheBall

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef redColor = [[UIColor redColor] CGColor];
    CGContextSetFillColorWithColor(context, redColor);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, 20, 20));
}


@end
