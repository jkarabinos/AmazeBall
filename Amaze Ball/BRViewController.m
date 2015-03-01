//
//  BRViewController.m
//  Amaze Ball
//
//  Created by John Karabinos on 1/17/15.
//  Copyright (c) 2015 John Karabinos. All rights reserved.
//



#import "BRViewController.h"
#import "TheBall.h"
#import "QuartzCore/CAAnimation.h"
#import "BRLevelSelectViewController.h"
#import "LevelCompleteView.h"

@interface BRViewController ()
@property (strong, nonatomic) UIImageView *ballView;
@property (strong, nonatomic) NSMutableArray* levelArray;
@property (nonatomic) int ballX;
@property (nonatomic) int ballY;
@property (strong, nonatomic) NSMutableDictionary* oneWayWalls;
//a mutable dictionary that will store references to the one way wall image views. We need this in order to later rotate the one way walls when the user moves through them in the appropriate direction

@property (strong, nonatomic) NSMutableDictionary* gates;
//similar to the one way wall dictionary, but necessary to create the gate animations

@property (strong, nonatomic) UIView* levelView;
@property (nonatomic) bool animating;

@property (nonatomic) int nextMove;
//an int that stores the next move that the user has made, this will increase the fluidity of the gameplay
// 1 = up, 2 = right, 3 = down, 4 = left

@property( nonatomic) int wallLength;
@property (nonatomic) int offset;

@property (strong, nonatomic) UIView* blackStartView;

//@property (strong, nonatomic) UIImageView* levelBack;

@end

@implementation BRViewController

#define ballSpeed 150.0
#define travelTime .8

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.animating = NO;
    _nextMove = 0;
    [self loadNextLevel];
    
    [self.blackStartView removeFromSuperview];
    self.blackStartView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2000, 2000)];
    self.blackStartView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.blackStartView];

    
    //[self setBackImage];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:.25 animations:^{
        self.blackStartView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.blackStartView removeFromSuperview];
        
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)loadNextLevel{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray* levels = [defaults objectForKey:@"levels"];
    
    int currentLevel = [[defaults objectForKey:@"currentLevel"] intValue];
    if([levels count]>currentLevel){
    
        self.levelArray = [[NSMutableArray alloc] initWithArray:levels[currentLevel]];
    
        [self drawCurrentLevelAndReloadBall:YES];
    }
    
}

-(void)setBackImage{
    int level = [[[NSUserDefaults standardUserDefaults] objectForKey:@"currentLevel"] intValue];
    int levelPack = level/25;
    if(levelPack==0){
        //self.backgroundImage.image = [UIImage imageNamed:@"bs1"];
        self.backgroundImage.image = [UIImage imageNamed:@"bs4"];
    }else if(levelPack==1){
        self.backgroundImage.image = [UIImage imageNamed:@"bs7"];
    }else if(levelPack==2){
        self.backgroundImage.image = [UIImage imageNamed:@"bs5"];
    }else if(levelPack==3){
        self.backgroundImage.image = [UIImage imageNamed:@"bs4"];
    }
    
}

-(void)removeAllSubviewsAndView:(UIView*) tempView{
    NSArray* subviews = tempView.subviews;
    
  
    for(int i=0; i<[subviews count]; i++){
        UIView* tempSubview = subviews[i];
        [tempSubview removeFromSuperview];
    }
    [tempView removeFromSuperview];
    
    //[self.levelBack removeFromSuperview];
    
}

/*
-(void)removeSubviewsRecursively:(NSArray*)subviews withIndex:(int)index{
    if(index>=0){
        UIView* subview = subviews[index];
        [UIView animateWithDuration:.01 animations:^{
            subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y, subview.frame.size.width*4, subview.frame.size.height*4);
            subview.alpha = .2;
        } completion:^(BOOL finished) {
            [subview removeFromSuperview];
            [self removeSubviewsRecursively:subviews withIndex:index-1];
        }];
    }else{
        [self shrinkLevelView];
        //[self showNextButton];
    }
}*/

/*
-(void) shrinkLevelView{
    [UIView animateWithDuration:.25 animations:^{
        self.levelView.frame = CGRectMake(self.levelView.frame.origin.x+self.levelView.frame.size.width/2, self.levelView.frame.origin.y+ self.levelView.frame.size.height/2,  0 , 0);
    } completion:^(BOOL finished) {
        [self showNextButton];
    }];
}
*/

//
-(void)drawCurrentLevelAndReloadBall:(bool) reloadBall{
    [self hideNextButton];
    NSLog(@"adding a level view");
    //[self.levelView removeFromSuperview];
    [self removeAllSubviewsAndView:self.levelView];
    
    self.levelView = [[UIView alloc] initWithFrame:CGRectMake(8, 115, 305, 305)];
    self.levelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8]; //[UIColor blackColor];
    
    //self.levelBack = [[UIImageView alloc] initWithFrame:self.levelView.frame];
    //self.levelBack.image = [UIImage imageNamed:@"levelback1"];
    //[self.view addSubview:self.levelBack];
    
    [self.view addSubview:self.levelView];
    /*UIImageView* back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rect2985"]];
    back.frame = CGRectMake(0, 0, 305, 305);
    [self.levelView addSubview:back];*/
    self.oneWayWalls = [[NSMutableDictionary alloc] init];
    self.gates = [[NSMutableDictionary alloc] init];
    
    
    [self drawBackgroundLines];
    //draws the thin lines that separate the boxes
    
    UIColor* wallColor = [[UIColor alloc] initWithRed:.2 green:.5 blue:.8 alpha:1];
    
    //add the corners
    //[self addCorners:wallColor];
    
    
    for(int i=0; i<21; i++){
        NSMutableArray* currentRow = self.levelArray[i];
        for(int j=0; j<11; j++){
            if(j==10 && i%2==0){
                
            }else{
                int wallMarker = [currentRow[j] intValue];
                bool outsideWall = NO;
                //this will mark if we are currently attempting to draw an outside wall rather than an inner wall
                _wallLength = 25;
                _offset = 5;
                if(i==0 || i==20 || (j==0 && i%2==1) || j==10){
                    _wallLength = 35;
                    _offset = 0;
                    outsideWall=YES;
                }
                if(wallMarker==1){
                    //standard wall
                    UIImageView*tempView = [[UIImageView alloc] init];
                    //tempView.backgroundColor = wallColor;
                    
                    if(i%2==0){
                        //if we are on an even row, we want a horizontal wall
                       
                        tempView.frame = CGRectMake(_offset+j*30, (i/2)*30, _wallLength, 5);
                        tempView.image = [UIImage imageNamed:@"wall5hor.png"];
                    }else{
                        tempView.frame = CGRectMake(j*30, _offset+(i/2)*30, 5, _wallLength);
                        tempView.image = [UIImage imageNamed:@"wall5.png"];
                    }
                    [self.levelView addSubview:tempView];
                }else if(wallMarker==2){
                    //spikewall with spikes on top or left
                    UIImageView* tempView = [[UIImageView alloc] init];
                    if(outsideWall){
                        //[self drawOutsideFirstWithI:i andJ:j];
                    }
                    //tempView.backgroundColor = wallColor;
                    if(i%2==0){
                        tempView.frame = CGRectMake(5+j*30, (i/2)*30-1, 25, 6);
                        tempView.image = [UIImage imageNamed:@"spikewall2.png"];
                    }else{
                        tempView.frame = CGRectMake(j*30-1, 5+(i/2)*30, 6, 25);
                        tempView.image = [UIImage imageNamed:@"spikewallleft.png"];
                    }
                    [self.levelView addSubview:tempView];
                }else if(wallMarker==3){
                    //spikewall with spikes on right or bottom
                    UIImageView* tempView =[[UIImageView alloc] init];
                    if(outsideWall){
                        //[self drawOutsideFirstWithI:i andJ:j];
                    }
                    //tempView.backgroundColor = wallColor;
                    if(i%2==0){
                        tempView.frame = CGRectMake(5+j*30, (i/2)*30, 25, 6);
                        tempView.image = [UIImage imageNamed:@"spikewalldown.png"];
                    }else{
                        tempView.frame = CGRectMake(j*30, 5+(i/2)*30, 6, 25);
                        tempView.image = [UIImage imageNamed:@"spikewallright.png"];
                    }
                    [self.levelView addSubview:tempView];
                }else if(wallMarker==4){
                    //siipkewall on both sides
                    UIView* tempView = [self getTwoWaySpikeWallWithI:i withJ:j];
                    [self.levelView addSubview:tempView];
                }else if(wallMarker==5){
                    //bouncewall with bounce on left or top
                    UIView*tempView = [self getBounceWall1:wallColor withI:i withJ:j];
                    [self.levelView addSubview:tempView];
                }else if(wallMarker==6){
                    //bouncewall with bounce on right or bottom
                    UIView*tempView = [self getBounceWall2:wallColor withI:i withJ:j];
                    [self.levelView addSubview:tempView];
                }else if(wallMarker==7){
                    //bouncewall with bounce on both sides
                    UIImageView* tempView = [[UIImageView alloc] init];
                    if(i%2==0){
                        tempView.frame = CGRectMake(5+j*30, (i/2)*30-1, 25, 7);
                        tempView.image = [UIImage imageNamed:@"bwallhor"];
                        
                    }else{
                        tempView.frame =CGRectMake(j*30-1, 5+(i/2)*30, 7, 25);
                        //tempView.backgroundColor = [UIColor whiteColor];
                        tempView.image = [UIImage imageNamed:@"bwall"];
                    }
                    [self.levelView addSubview:tempView];
                }else if(wallMarker==8){
                    //one way wall with one way side on the top or left
                    UIView* tempView = [self getOneWayWall1:wallColor withI:i withJ:j];
                    [self.levelView addSubview:tempView];
                }else if(wallMarker==9){
                    //one way wall with one way side on the right or bottom
                    UIView* tempView = [self getOneWayWall2:wallColor withI:i withJ:j];
                    [self.levelView addSubview:tempView];
                }else if(wallMarker==10){
                    //if the wall is a disappearing wall
                    UIView* tempView =[self getDisappearingWallWithI:i withJ:j];
                    [self.levelView addSubview:tempView];
                }else if(wallMarker==11){
                    //if the wall is a gate
                   [self getGateWithI:i withJ:j];
                }else if(wallMarker==0 && j==10){
                    UIImageView* arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"a4right.png"]];
                    arrow.frame = CGRectMake(272, (i/2)*30+2, 30, 30);
                    [self.levelView addSubview:arrow];
                }else if(wallMarker==0 && j==0 && i%2==1){
                    UIImageView* arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"a4left.png"]];
                    arrow.frame = CGRectMake(2, (i/2)*30+2, 30, 30);
                    [self.levelView addSubview:arrow];
                }else if(wallMarker==0 && i==0){
                    UIImageView* arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"a4up.png"]];
                    arrow.frame = CGRectMake(j*30+2, 2, 30, 30);
                    [self.levelView addSubview:arrow];
                }else if(wallMarker==0 && i==20){
                    UIImageView* arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"a4down.png"]];
                    arrow.frame = CGRectMake(j*30+2, 272, 30, 30);
                    [self.levelView addSubview:arrow];
                }
            }
        }
    }
    
    if(reloadBall){
        //if we are reloading a level that is in progress, we do not want to change the position of the ball
        NSArray* ballStart = self.levelArray[21];
        self.ballX=[ballStart[0] intValue];
        self.ballY=[ballStart[1] intValue];
    }
    
    self.ballView = [[UIImageView alloc] initWithFrame:CGRectMake(8+(30*self.ballX), 8+(30*(self.ballY/2)), 20, 20)];
    //self.ballView.backgroundColor = [UIColor clearColor];
    self.ballView.image = [UIImage imageNamed:@"ball2.png"];
    
    [self.levelView addSubview:self.ballView];
    
    int level = [[[NSUserDefaults standardUserDefaults] objectForKey:@"currentLevel"] intValue];
    self.levelLabel.text = [@"Level " stringByAppendingString:[@((level)%25+1) stringValue]];

    self.animating = NO;
    
}

-(void)drawOutsideFirstWithI:(int) i andJ:(int) j{
    //(i==0 || i==20 || (j==0 && i%2==1) || j==10)
    UIImageView* tempView = [[UIImageView alloc] init];
    if(i%2==0){
        //if we are on an even row, we want a horizontal wall
        if(i==0){
            tempView.frame = CGRectMake(_offset+j*30, (i/2)*30, _wallLength, 3);
        }if(i==20){
            tempView.frame = CGRectMake(_offset+j*30, (i/2)*30+2, _wallLength, 3);
        }
        tempView.image = [UIImage imageNamed:@"wall5hor.png"];
    }else{
        tempView.frame = CGRectMake(j*30, _offset+(i/2)*30, 5, _wallLength);
        tempView.image = [UIImage imageNamed:@"wall5.png"];
    }
    [self.levelView addSubview:tempView];
}


-(void)getGateWithI:(int) i withJ:(int) j{
    UIView* largeView1 = [[UIView alloc] init];
    UIView* largeView2 = [[UIView alloc] init];
    UIImageView* tempView1 = [[UIImageView alloc] init];
    UIImageView* tempView2 = [[UIImageView alloc] init];
    if(i%2==0){
        largeView1.frame = CGRectMake(5+j*30-9, (i/2)*30, 21, 5);
        largeView2.frame =CGRectMake (18+j*30, (i/2)*30, 21, 5);
        tempView1.frame = CGRectMake(9, 0, 12, 5);
        tempView2.frame = CGRectMake(0, 0, 12, 5);
        tempView1.image = [UIImage imageNamed:@"gateright"];
        tempView2.image = [UIImage imageNamed:@"gateleft"];
    }else{
        largeView1.frame = CGRectMake(j*30, 5+(i/2)*30-9, 5, 21);
        largeView2.frame = CGRectMake(j*30, 18+(i/2)*30, 5, 21);
        tempView1.frame = CGRectMake(0, 9, 5, 12);
        tempView2.frame = CGRectMake(0, 0, 5, 12);
        tempView1.image = [UIImage imageNamed:@"gate"];
        tempView2.image = [UIImage imageNamed:@"gatetop"];
    }
    [largeView1 addSubview:tempView1];
    [largeView2 addSubview:tempView2];
    
    NSString* key1 = [[[[@(j) stringValue] stringByAppendingString:@"-"] stringByAppendingString:[@(i) stringValue]] stringByAppendingString:@"-1"];
    NSString* key2 = [[[[@(j) stringValue] stringByAppendingString:@"-"] stringByAppendingString:[@(i) stringValue]] stringByAppendingString:@"-2"];
    [self.gates setObject:largeView1 forKey:key1];
    [self.gates setObject:largeView2 forKey:key2];
    
    [self.levelView addSubview:largeView1];
    [self.levelView addSubview:largeView2];
}

-(UIView*)getTwoWaySpikeWallWithI:(int)i withJ:(int) j{
    UIView* tempView = [[UIView alloc] init];
    tempView.backgroundColor = [UIColor orangeColor];
    if(i%2==0){
        tempView.frame = CGRectMake(2+j*30, (i/2)*30, 31, 5);
    }else{
        tempView.frame = CGRectMake(j*30, 2+(i/2)*30, 5, 31);
    }
    return tempView;

}

-(UIImageView*)getDisappearingWallWithI:(int) i withJ:(int) j{
    UIImageView* tempView = [[UIImageView alloc] init];
    //tempView.backgroundColor = [UIColor purpleColor];
    tempView.image = [UIImage imageNamed:@"disappearingwallhor.png"];
    if(i%2==0){
        tempView.frame = CGRectMake(5+j*30, (i/2)*30, 25, 5);
    }else{
        tempView.frame = CGRectMake(j*30, 5+(i/2)*30, 5, 25);
    }
    return tempView;
}

-(UIView*)getOneWayWall1:(UIColor*) wallColor withI:(int) i withJ:(int) j{
    UIView* tempView = [[UIView alloc] init];
    UIImageView* stopper = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box2.png"]];
    UIImageView* wall = [[UIImageView alloc] init];
    if(i%2==0){
        tempView.frame = CGRectMake(-15+j*30, (i/2)*30, 45, 5);
        wall.frame = CGRectMake(20, 0, 25, 5);
        wall.image = [UIImage imageNamed:@"one-way-hor.png"];
        stopper.frame = CGRectMake(26+j*30, (i/2)*30-2, 4, 3);
        [self.levelView addSubview:stopper];
    }else{
        tempView.frame = CGRectMake(j*30, 5+(i/2)*30, 5, 45);
        wall.frame = CGRectMake(0, 0, 5, 25);
        wall.image = [UIImage imageNamed:@"one-way-lefttoright.png"];
        stopper.frame = CGRectMake(-2+j*30, (i/2)*30+5, 3, 4);
        [self.levelView addSubview:stopper];
    }
    NSString* key = [[[@(j) stringValue] stringByAppendingString:@"-"] stringByAppendingString:[@(i) stringValue]];
    [self.oneWayWalls setObject:tempView forKey:key];
    [tempView addSubview:wall];
    return tempView;
}
-(UIView*)getOneWayWall2:(UIColor*) wallColor withI:(int) i withJ:(int) j{
    UIView* tempView = [[UIView alloc] init];
    //UIColor* oneWayWallColor = [[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:.5];
    //tempView.backgroundColor = oneWayWallColor;
    UIImageView* wall = [[UIImageView alloc] init];
    UIImageView* stopper = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box2.png"]];
    if(i%2==0){
        tempView.frame = CGRectMake(5+j*30, (i/2)*30, 45, 5);
        wall.frame = CGRectMake(0, 0, 25, 5);
        wall.image = [UIImage imageNamed:@"one-way-bottomtotop.png"];
        stopper.frame = CGRectMake(5+j*30, (i/2)*30+4, 4, 3);
        /*UIView* wallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 31, 2)];
        wallView.backgroundColor = wallColor;
        [tempView addSubview:wallView];*/
    }else{
        tempView.frame = CGRectMake(j*30, -15+(i/2)*30, 5, 45);
        wall.frame = CGRectMake(0, 20, 5, 25);
        wall.image = [UIImage imageNamed:@"one-way-righttoleft"];
        stopper.frame = CGRectMake(4+j*30, (i/2)*30+26, 3, 4);
        /*UIView* wallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 31)];
        wallView.backgroundColor = wallColor;
        [tempView addSubview:wallView];*/
    }
    [self.levelView addSubview:stopper];
    NSString* key = [[[@(j) stringValue] stringByAppendingString:@"-"] stringByAppendingString:[@(i) stringValue]];
    [self.oneWayWalls setObject:tempView forKey:key];
    [tempView addSubview:wall];
    return tempView;
}



-(UIImageView*)getBounceWall1:(UIColor*) wallColor withI:(int) i withJ:(int) j{
    UIImageView*tempView = [[UIImageView alloc] init];
    if(i%2==0){
        tempView.frame = CGRectMake(5+j*30, (i/2)*30-1, 25, 6);
        tempView.image = [UIImage imageNamed:@"bwallup"];
    }else{
        tempView.frame = CGRectMake(j*30-1, 5+(i/2)*30, 6, 25);
        tempView.image = [UIImage imageNamed:@"bwallleft"];
    }
    return tempView;
}

-(UIImageView*)getBounceWall2:(UIColor*) wallColor withI:(int) i withJ:(int) j{
    UIImageView*tempView = [[UIImageView alloc] init];
    if(i%2==0){
        tempView.frame = CGRectMake(5+j*30, (i/2)*30, 25, 6);
        tempView.image = [UIImage imageNamed:@"bwalldown"];
    }else{
        tempView.frame = CGRectMake(j*30, 5+(i/2)*30, 6, 25);
        tempView.image = [UIImage imageNamed:@"bwallright"];
    }
    return tempView;
}

-(void)addCorners:(UIColor*) wallColor{
    UIView* corner1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    UIView* corner2 = [[UIView alloc] initWithFrame:CGRectMake(300, 0, 5, 5)];
    UIView* corner3 = [[UIView alloc] initWithFrame:CGRectMake(0, 300, 5, 5)];
    UIView* corner4 = [[UIView alloc] initWithFrame:CGRectMake(300, 300, 5, 5)];
    
    
    corner1.backgroundColor = wallColor;
    corner2.backgroundColor = wallColor;
    corner3.backgroundColor = wallColor;
    corner4.backgroundColor = wallColor;
    
    [self.levelView addSubview:corner1];
    [self.levelView addSubview:corner2];
    [self.levelView addSubview:corner3];
    [self.levelView addSubview:corner4];

}

-(void)drawBackgroundLines{
    for(int i=0; i<9; i++){
        UIView* tempView = [[UIView alloc] initWithFrame:CGRectMake(2+30*(i+1), 2, 1, 300)];
        tempView.backgroundColor = [UIColor darkGrayColor];
        [self.levelView addSubview:tempView];
    }
    //draw the thin vertical white lines
    
    for(int i=0; i<9; i++){
        UIView* tempView = [[UIView alloc] initWithFrame:CGRectMake(2, 2+30*(i+1), 300, 1)];
        tempView.backgroundColor = [UIColor darkGrayColor];
        [self.levelView addSubview:tempView];
    }
    //draw the thin horizontal white lines
    
}

-(void)finishedLevel{
    NSLog(@"win!!!!");
    _nextMove = 0;
    /*
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    int currentLevel = [[defaults objectForKey:@"currentLevel"] intValue];
    currentLevel++;
    [defaults setObject:[NSNumber numberWithInt:currentLevel ] forKey:@"currentLevel"];
    
    [self.levelView removeFromSuperview];
    
    [self loadNextLevel];
    */
    
    //[self removeSubviewsRecursively:self.levelView.subviews withIndex:[self.levelView.subviews count]-1];

    LevelCompleteView* lcv = [LevelCompleteView lcv];
    
    
    //our final width and height should be 250 and 80, we will calculate the initial width and height based off of these values
    
    float width =self.view.frame.size.width;
    
    UIImageView* levelCompView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lc7"]];
    levelCompView.frame =CGRectMake(-self.levelView.frame.origin.x, 0, width, (width*80)/250);
    [self.levelView addSubview:levelCompView];
    
    /*
     float width = lcv.frame.size.width;
     float height = lcv.frame.size.height;
     lcv.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
     lcv.parentViewController = self;
     [self.levelView addSubview:lcv];*/
    
    self.nextButton.userInteractionEnabled = YES;
    self.nextButton.hidden = NO;
    [UIView animateWithDuration:.5 animations:^{
        //lcv.frame =CGRectMake(27, 100, width, height);
        levelCompView.frame =CGRectMake(27, 100, 250, 80);
        self.ballView.alpha = 0;
        self.nextButton.alpha =1;
    }];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    int playableLevel = [[defaults objectForKey:@"playableLevel"] intValue];
    int currentLevel = [[defaults objectForKey:@"currentLevel"] intValue];
    if((currentLevel+1)>playableLevel){
        //if the user has beaten a level that they have not previously completed
        [defaults setObject:@(currentLevel+1) forKey:@"playableLevel"];
    }
    
    //[self nextLevel];
}
/*
-(void)showNextButton{
    LevelCompleteView* lcv = [LevelCompleteView lcv];
    
    
    //our final width and height should be 250 and 80, we will calculate the initial width and height based off of these values
    
    float width =self.view.frame.size.width;
    
    UIImageView* levelCompView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lc7"]];
    levelCompView.frame =CGRectMake(-self.levelView.frame.origin.x, 0, width, (width*80)/250);
    [self.levelView addSubview:levelCompView];
    
 
     //float width = lcv.frame.size.width;
     //float height = lcv.frame.size.height;
     //lcv.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
     //lcv.parentViewController = self;
     //[self.levelView addSubview:lcv];
    
    self.nextButton.userInteractionEnabled = YES;
    self.nextButton.hidden = NO;
    [UIView animateWithDuration:.5 animations:^{
        //lcv.frame =CGRectMake(27, 100, width, height);
        levelCompView.frame =CGRectMake(-125, -50, 250, 80);
        self.ballView.alpha = 0;
        self.nextButton.alpha =1;
    }];
}*/

-(void) restartLevel{
    //[self.levelView removeFromSuperview];
    [self loadNextLevel];
}

-(void)addNewRowAtIndex:(int) row forWall:(int) wall{
    NSMutableArray* copy = [[NSMutableArray alloc] init];
    copy =[self.levelArray[row] mutableCopy];
    copy[wall] = [NSNumber numberWithInt:0];
    NSArray* newRow = [[NSArray alloc] initWithArray:copy];
    self.levelArray[row] = newRow;
}

- (IBAction)swipeRight:(id)sender {
    if(!_animating){
        _animating = YES;
        _nextMove = 0;
        bool completedLevel = NO;
        bool lostLevel = NO;
        bool bounceBack = NO;
        bool needToReloadLevel = NO;
        NSMutableArray* oneWays = [[NSMutableArray alloc] init];
        NSMutableArray* gates = [[NSMutableArray alloc] init];
        
        NSMutableArray* verticalWalls = self.levelArray[self.ballY];
        int firstWall=-1;
        for(int i=self.ballX+1; i<[verticalWalls count]; i++){
            if([verticalWalls[i] intValue]==1 || [verticalWalls[i] intValue] ==3 || [verticalWalls[i] intValue]==6 || [verticalWalls[i] intValue]==9 || ([verticalWalls[i] intValue]==11 && (i -_ballX)<4)){
                firstWall = i;
                break;
            }else if([verticalWalls[i] intValue]==2 || [verticalWalls[i] intValue]==4){
                firstWall = i;
                lostLevel = YES;
                break;
            }else if([verticalWalls[i] intValue]==7 || [verticalWalls[i] intValue]==5){
                firstWall = i;
                bounceBack = YES;
                break;
            }else if([verticalWalls[i] intValue]==10){
                firstWall = i;
                [self addNewRowAtIndex:self.ballY forWall:i];
                needToReloadLevel = YES;
                break;
            }else if([verticalWalls[i] intValue] ==8){
                [oneWays addObject:[NSNumber numberWithInt:i]];
            }else if([verticalWalls[i] intValue]==11 && (i-_ballX)>3){
                //if we are moving through a gate, we want to save it so that we can animate it openning
                [gates addObject:[NSNumber numberWithInt:i]];
            }
        }
        if(firstWall==-1){
        //that is, if there is no wall and the player has completed the level
            firstWall = 11;
            completedLevel =YES;
            // so that the ball will move out of the level
        }
    
        int travelDistance = 30*(firstWall-self.ballX-1);
        self.ballX= firstWall-1;
        
        for(int h=0; h<[oneWays count];h++){
            NSString* key = [[[oneWays[h] stringValue] stringByAppendingString:@"-"] stringByAppendingString:[@(_ballY) stringValue]];
            UIView* tempView = [self.oneWayWalls objectForKey:key];
            [self openDoor:tempView withDirection:1];
        }
        for(int j=0; j<[gates count]; j++){
            NSString* key1 = [[[[gates[j] stringValue] stringByAppendingString:@"-"] stringByAppendingString:[@(_ballY) stringValue]] stringByAppendingString:@"-1"];
             NSString* key2 = [[[[gates[j] stringValue] stringByAppendingString:@"-"] stringByAppendingString:[@(_ballY) stringValue]] stringByAppendingString:@"-2"];
            UIView* tempView1 = [self.gates objectForKey:key1];
            UIView* tempView2 = [self.gates objectForKey:key2];
            [self openDoor:tempView1 withDirection:2];
            [self openDoor:tempView2 withDirection:1];
        }
        
        [UIView animateWithDuration:travelTime animations:^{
            self.ballView.frame = CGRectMake(self.ballView.frame.origin.x + travelDistance, self.ballView.frame.origin.y, 20, 20);
        }completion:^(BOOL finished){
            if(completedLevel){
                [self finishedLevel];
            }
        
            if(lostLevel){
                [self restartLevel];
            }if(bounceBack){
                [self bounceBack:-1 onAxis:@"x"withX:firstWall withY:_ballY];
            }if(needToReloadLevel){
                [self reloadLevel];
            }if(!bounceBack && !completedLevel){
                _animating = NO;
                if(_nextMove!=0){
                    //if the user has inputed a next move since his swipe right
                    [self applyNextMove];
                }
            }
        }];
    }else{
        //if the ball is already moving, we want to store the next move that the user has inputed
        _nextMove = 2;
    }
}

- (IBAction)swipeLeft:(id)sender {
    if(!_animating){
        _animating = YES;
        _nextMove =0;
    
    bool completedLevel = NO;
    bool lostLevel = NO;
    bool bounceBack =NO;
        bool needToReloadLevel = NO;
        NSMutableArray* oneWays = [[NSMutableArray alloc] init];
        NSMutableArray* gates = [[NSMutableArray alloc] init];
    
    NSMutableArray* verticalWalls = self.levelArray[self.ballY];
    int firstWall = -1;
    for(int i=self.ballX; i>-1; i--){
        if([verticalWalls[i] intValue]==1 || [verticalWalls[i] intValue] ==2 || [verticalWalls[i] intValue]==5 || [verticalWalls[i] intValue]==8 || ([verticalWalls[i] intValue]==11 && (_ballX-i)<3)){
            firstWall = i;
            break;
        }else if([verticalWalls[i] intValue]==3 || [verticalWalls[i] intValue]==4){
            firstWall = i;
            lostLevel = YES;
            break;
        }else if([verticalWalls[i] intValue]==7 || [verticalWalls[i] intValue]==6){
            firstWall = i;
            bounceBack = YES;
            break;
        }else if([verticalWalls[i] intValue] ==10){
            firstWall = i;
            [self addNewRowAtIndex:self.ballY forWall:i];
            needToReloadLevel = YES;
            break;
        }else if([verticalWalls[i] intValue]==9){
            [oneWays addObject:[NSNumber numberWithInt:i]];
        }else if([verticalWalls[i] intValue]==11 && (_ballX-i)>=3){
            [gates addObject:[NSNumber numberWithInt:i]];
        }
    }
    NSLog(@"first wall at %i", firstWall);
    if(firstWall==-1){
        firstWall = -1;
        completedLevel =YES;
    }
    int travelDistance = 30*(firstWall-self.ballX);
    self.ballX=firstWall;
        
        for(int h=0; h<[oneWays count];h++){
            NSString* key = [[[oneWays[h] stringValue] stringByAppendingString:@"-"] stringByAppendingString:[@(_ballY) stringValue]];
            UIView* tempView = [self.oneWayWalls objectForKey:key];
            [self openDoor:tempView withDirection:1];
        }
        for(int j=0; j<[gates count]; j++){
            NSString* key1 = [[[[gates[j] stringValue] stringByAppendingString:@"-"] stringByAppendingString:[@(_ballY) stringValue]] stringByAppendingString:@"-1"];
            NSString* key2 = [[[[gates[j] stringValue] stringByAppendingString:@"-"] stringByAppendingString:[@(_ballY) stringValue]] stringByAppendingString:@"-2"];
            UIView* tempView1 = [self.gates objectForKey:key1];
            UIView* tempView2 = [self.gates objectForKey:key2];
            [self openDoor:tempView1 withDirection:1];
            [self openDoor:tempView2 withDirection:2];
        }

        //float travelTime = -travelDistance / ballSpeed;
    
    [UIView animateWithDuration:travelTime animations:^{
        self.ballView.frame = CGRectMake(self.ballView.frame.origin.x + travelDistance, self.ballView.frame.origin.y, 20, 20);
    }completion:^(BOOL finished){
        if(completedLevel){
            [self finishedLevel];
        }if(lostLevel){
            [self restartLevel];
        }if(bounceBack){
            [self bounceBack:1 onAxis:@"x" withX:firstWall withY:_ballY];
        }if(needToReloadLevel){
            [self reloadLevel];
        }if(!bounceBack && !completedLevel){
            _animating = NO;
            if(_nextMove!=0){
                [self applyNextMove];
            }
        }
    }];
    }else{
        _nextMove=4;
    }
}

- (IBAction)swipeDown:(id)sender {
    if(!_animating){
        _animating = YES;
        _nextMove=0;
        bool completedLevel = NO;
        bool lostLevel = NO;
        bool bounceBack =NO;
        bool needToReloadLevel = NO;
    NSLog(@"Swiped down");
    int firstWall=-1;
        NSMutableArray* oneWays = [[NSMutableArray alloc] init];
        NSMutableArray* gates = [[NSMutableArray alloc] init];
    for(int i=_ballY+1; i<21; i=i+2){
        //we only want to look at the possible horizontal walls
        NSMutableArray* horizontalWalls = self.levelArray[i];
        if([horizontalWalls[_ballX] intValue]==1 || [horizontalWalls[_ballX] intValue]==3 || [horizontalWalls[_ballX] intValue]==6 ||[horizontalWalls[_ballX] intValue]==9 || ([horizontalWalls[_ballX] intValue]==11 && (i-_ballY)<6)){
            firstWall = i;
            break;
        }else if([horizontalWalls[_ballX] intValue]==2 || [horizontalWalls[_ballX] intValue]==4){
            //if the ball hits the spikey side of a wall
            firstWall = i;
            lostLevel = YES;
            break;
        }else if([horizontalWalls[_ballX] intValue]==7 || [horizontalWalls[_ballX] intValue]==5){
            firstWall =i;
            bounceBack =YES;
            break;
        }else if([horizontalWalls[_ballX] intValue]==10){
            firstWall =i;
            needToReloadLevel = YES;
            [self addNewRowAtIndex:i forWall:_ballX];
            break;
        }else if([horizontalWalls[_ballX] intValue]==8){
            //to make a one way wall swing open
            [oneWays addObject:[NSNumber numberWithInt:i]];
        }else if([horizontalWalls[_ballX] intValue]==11 && (i-_ballY)>6){
            [gates addObject:[NSNumber numberWithInt:i]];
        }
    }
    if(firstWall==-1){
        firstWall = 22;
        completedLevel =YES;
    }
    
    int travelDistance = 30*((firstWall-self.ballY-1)/2);
        
        self.ballY=firstWall-1;
        
        for(int h=0; h<[oneWays count]; h++){
            NSString* key = [[[@(_ballX) stringValue] stringByAppendingString:@"-"] stringByAppendingString:[oneWays[h] stringValue]];
            UIView* tempView = [self.oneWayWalls objectForKey:key];
            [self openDoor:tempView withDirection:1];
        }
        for(int j=0; j<[gates count]; j++){
            NSString* key1 = [[[[@(_ballX) stringValue] stringByAppendingString:@"-"] stringByAppendingString:[gates[j] stringValue]] stringByAppendingString:@"-1"];
            NSString* key2 = [[[[@(_ballX) stringValue] stringByAppendingString:@"-"] stringByAppendingString:[gates[j] stringValue]] stringByAppendingString:@"-2"];
            UIView* tempView1 = [self.gates objectForKey:key1];
            UIView* tempView2 = [self.gates objectForKey:key2];
            [self openDoor:tempView1 withDirection:1];
            [self openDoor:tempView2 withDirection:2];
        }

    [UIView animateWithDuration:travelTime animations:^{
        self.ballView.frame = CGRectMake(self.ballView.frame.origin.x , self.ballView.frame.origin.y+ travelDistance, 20, 20);;
    }completion:^(BOOL finished){
        if(completedLevel){
            [self finishedLevel];
        }if(lostLevel){
            [self restartLevel];
        }if(bounceBack){
            [self bounceBack:-1 onAxis:@"y" withX:_ballX withY:firstWall];
        }if(needToReloadLevel){
            [self reloadLevel];
        }if(!bounceBack && !completedLevel){
            _animating = NO;
            if(_nextMove!=0){
                [self applyNextMove];
            }
        }
    }];
    }else{
        _nextMove = 3;
    }

}
- (IBAction)swipeUp:(id)sender {
    if(!_animating){
        _animating = YES;
        _nextMove = 0;
    bool completedLevel = NO;
    bool lostLevel =NO;
    bool bounceBack = NO;
        bool needToReloadLevel=NO;
    NSLog(@"Swiped up");
    int firstWall=-1;
        NSMutableArray* oneWays = [[NSMutableArray alloc] init];
        NSMutableArray* gates = [[NSMutableArray alloc] init];
    for(int i=_ballY-1; i>-1; i=i-2){
        //we only want to look at the possible horizontal walls
        NSMutableArray* horizontalWalls = self.levelArray[i];
        if([horizontalWalls[_ballX] intValue]==1 || [horizontalWalls[_ballX] intValue]==2 || [horizontalWalls[_ballX] intValue]==5 || [horizontalWalls[_ballX] intValue]==8 || ([horizontalWalls[_ballX] intValue]==11 && (_ballY-i)<6)){
            firstWall = i;
            break;
        }else if([horizontalWalls[_ballX] intValue]==3 || [horizontalWalls[_ballX] intValue]==4){
            firstWall = i;
            lostLevel =YES;
            break;
        }else if([horizontalWalls[_ballX] intValue]==7 || [horizontalWalls[_ballX] intValue] ==6){
            firstWall =i;
            bounceBack = YES;
            break;
        }else if([horizontalWalls[_ballX] intValue]==10){
            firstWall = i;
            needToReloadLevel = YES;
            [self addNewRowAtIndex:i forWall:_ballX];
            break;
        }else if([horizontalWalls[_ballX] intValue]==9){
            [oneWays addObject:[NSNumber numberWithInt:i]];
        }else if([horizontalWalls[_ballX] intValue]==11 && (_ballY-i)>6){
            [gates addObject:[NSNumber numberWithInt:i]];
        }
    }
    if(firstWall==-1){
        firstWall = -2;
        completedLevel =YES;
    }
    int travelDistance = 30*((firstWall-self.ballY+1)/2);
    self.ballY=firstWall+1;
        //float travelTime = -travelDistance / ballSpeed;
        for(int h=0; h<[oneWays count]; h++){
            NSString* key = [[[@(_ballX) stringValue] stringByAppendingString:@"-"] stringByAppendingString:[oneWays[h] stringValue]];
            UIView* tempView = [self.oneWayWalls objectForKey:key];
            [self openDoor:tempView withDirection:1];
        }
        for(int j=0; j<[gates count]; j++){
            NSString* key1 = [[[[@(_ballX) stringValue] stringByAppendingString:@"-"] stringByAppendingString:[gates[j] stringValue]] stringByAppendingString:@"-1"];
            NSString* key2 = [[[[@(_ballX) stringValue] stringByAppendingString:@"-"] stringByAppendingString:[gates[j] stringValue]] stringByAppendingString:@"-2"];
            UIView* tempView1 = [self.gates objectForKey:key1];
            UIView* tempView2 = [self.gates objectForKey:key2];
            [self openDoor:tempView1 withDirection:2];
            [self openDoor:tempView2 withDirection:1];
        }


    
    [UIView animateWithDuration:travelTime animations:^{
         self.ballView.frame = CGRectMake(self.ballView.frame.origin.x , self.ballView.frame.origin.y+ travelDistance, 20, 20);
    }completion:^(BOOL finished){
        if(completedLevel){
            [self finishedLevel];
        }if(lostLevel){
            [self restartLevel];
        }if(bounceBack){
            [self bounceBack:1 onAxis:@"y" withX:_ballX withY:firstWall];
        }if(needToReloadLevel){
            [self reloadLevel];
        }if(!bounceBack && !completedLevel){
            _animating = NO;
            if(_nextMove!=0){
                [self applyNextMove];
            }
        }
    }];
    }else{
        _nextMove = 1;
    }
}

-(void)openDoor:(UIView*)tempView withDirection:(int) direction{
    [UIView animateWithDuration:.4 animations:^{
        if(direction==1){
            tempView.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
        else if(direction==2){
            tempView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
    } completion:^(BOOL finished) {
        [self performSelector:@selector(closeDoor:) withObject:tempView afterDelay:.39];
    }];

}

-(void)closeDoor:(UIView*) tempView{
    [UIView animateWithDuration:.4 animations:^{
        tempView.transform = CGAffineTransformMakeRotation(0);
    }];
}

-(void)applyNextMove{
    if(_nextMove==1){
        [self swipeUp:self];
    }else if(_nextMove==2){
        [self swipeRight:self];
    }else if(_nextMove==3){
        [self swipeDown:self];
    }else if(_nextMove==4){
        [self swipeLeft:self];
    }
}

- (IBAction)backButton:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    int currentLevel = [[defaults objectForKey:@"currentLevel"] intValue];
    if(currentLevel>0){
        currentLevel--;
    
        [defaults setObject:[NSNumber numberWithInt:currentLevel ] forKey:@"currentLevel"];
        //[self.levelView removeFromSuperview];
        [self loadNextLevel];
    }
    
}

- (IBAction)restartLevel:(id)sender {
    [self restartLevel];
}

- (IBAction)nextLevel:(id)sender {
    [self nextLevel];
}

- (IBAction)levelSelect:(id)sender {
    NSLog(@"select levels");
    
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    BRLevelSelectViewController *controller = (BRLevelSelectViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"levelSelect"];
    
    
    self.blackStartView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2000, 2000)];
    self.blackStartView.alpha = 0;
    self.blackStartView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.blackStartView];
    [UIView animateWithDuration:.25 animations:^{
        self.blackStartView.alpha = 1;
    } completion:^(BOOL finished) {
        //[self.levelView removeFromSuperview];
        [self presentViewController:controller animated:NO completion:nil];
        
    }];
    
    
    
}

-(void)hideNextButton{
    self.nextButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:.5 animations:^{
        self.nextButton.alpha = 0;
    } completion:^(BOOL finished) {
        self.nextButton.hidden = YES;
    }];
}

-(void)nextLevel{
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    int currentLevel = [[defaults objectForKey:@"currentLevel"] intValue];
    NSArray* levels = [defaults objectForKey:@"levels"];
    if([levels count]>currentLevel+1){
        currentLevel++;
        
        [defaults setObject:[NSNumber numberWithInt:currentLevel ] forKey:@"currentLevel"];
        //[self.levelView removeFromSuperview];
        [self loadNextLevel];
    }

}

-(void)reloadLevel{
    //this method will only reload the view of the level, it will not restart the level
    //[self.levelView removeFromSuperview];
    [self drawCurrentLevelAndReloadBall:NO];
}

-(void)bounceBack:(int)direction onAxis:(NSString*)axis withX:(int)x withY:(int) y{

    
    if([axis isEqualToString:@"x"]){
        _ballX+=direction;
        [UIView animateWithDuration:.5 animations:^{
            self.ballView.frame = CGRectMake(self.ballView.frame.origin.x + direction*30, self.ballView.frame.origin.y, 20, 20);
        }completion:^(BOOL finished){
            _animating = NO;
            if(_nextMove!=0){
                [self applyNextMove];
            }
        }
         ];
    }else if([axis isEqualToString:@"y"]){
        _ballY+=direction*2;
        [UIView animateWithDuration:.5 animations:^{
            self.ballView.frame = CGRectMake(self.ballView.frame.origin.x , self.ballView.frame.origin.y+ direction*30, 20, 20);
        }completion:^(BOOL finished){
            _animating = NO;
            if(_nextMove!=0){
                [self applyNextMove];
            }
        }];

    }
}


#pragma mark - Navigation




@end
