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

@interface BRViewController ()
@property (strong, nonatomic) TheBall *ballView;
@property (strong, nonatomic) NSMutableArray* levelArray;
@property (nonatomic) int ballX;
@property (nonatomic) int ballY;

@property (strong, nonatomic) UIView* levelView;
@property (nonatomic) bool animating;


@end

@implementation BRViewController

#define ballSpeed 150.0
#define travelTime .8

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
}

-(void)viewDidAppear:(BOOL)animated{
    self.animating = NO;
    [self loadNextLevel];
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

-(void)drawCurrentLevelAndReloadBall:(bool) reloadBall{
    self.levelView = [[UIView alloc] initWithFrame:CGRectMake(8, 98, 305, 305)];
    self.levelView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.levelView];
    
    
    [self drawBackgroundLines];
    //draws the thin lines that separate the boxes
    
    UIColor* wallColor = [[UIColor alloc] initWithRed:.2 green:.5 blue:.8 alpha:1];
    
    //add the corners
    [self addCorners:wallColor];
    
    for(int i=0; i<21; i++){
        NSMutableArray* currentRow = self.levelArray[i];
        for(int j=0; j<11; j++){
            if(j==10 && i%2==0){
                
            }else{
                int wallMarker = [currentRow[j] intValue];
                if(wallMarker==1){
                    //standard wall
                    UIView*tempView = [[UIView alloc] init];
                    tempView.backgroundColor = wallColor;
                    if(i%2==0){
                        //if we are on an even row, we want a horizontal wall
                        tempView.frame = CGRectMake(2+j*30, (i/2)*30, 31, 5);
                    }else{
                        tempView.frame = CGRectMake(j*30, 2+(i/2)*30, 5, 31);
                    }
                    [self.levelView addSubview:tempView];
                }else if(wallMarker==2){
                    //spikewall with spikes on top or left
                    UIView* tempView = [[UIView alloc] init];
                    
                    tempView.backgroundColor = wallColor;
                    if(i%2==0){
                        tempView.frame = CGRectMake(2+j*30, (i/2)*30, 31, 5);
                        UIView* spikeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 31, 2)];
                        spikeView.backgroundColor = [UIColor orangeColor];
                        [tempView addSubview:spikeView];
                    }else{
                        tempView.frame = CGRectMake(j*30, 2+(i/2)*30, 5, 31);
                        UIView* spikeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 31)];
                        spikeView.backgroundColor =[UIColor orangeColor];
                        [tempView addSubview:spikeView];
                    }
                    [self.levelView addSubview:tempView];
                }else if(wallMarker==3){
                    //spikewall with spikes on right or bottom
                    UIView* tempView =[[UIView alloc] init];
                    tempView.backgroundColor = wallColor;
                    if(i%2==0){
                        tempView.frame = CGRectMake(2+j*30, (i/2)*30, 31, 5);
                        UIView* spikeView = [[UIView alloc] initWithFrame:CGRectMake(0, 3, 31, 2)];
                        spikeView.backgroundColor = [UIColor orangeColor];
                        [tempView addSubview:spikeView];
                    }else{
                        tempView.frame = CGRectMake(j*30, 2+(i/2)*30, 5, 31);
                        UIView* spikeView = [[UIView alloc] initWithFrame:CGRectMake(3, 0, 2, 31)];
                        spikeView.backgroundColor =[UIColor orangeColor];
                        [tempView addSubview:spikeView];
                    }
                    [self.levelView addSubview:tempView];
                }else if(wallMarker==4){
                    //siipkewall on both sides
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
                    UIView* tempView = [[UIView alloc] init];
                    if(i%2==0){
                        tempView.frame = CGRectMake(2+j*30, (i/2)*30-1, 31, 7);
                        tempView.backgroundColor = [UIColor whiteColor];
                    }else{
                        tempView.frame =CGRectMake(j*30-1, 2+(i/2)*30, 7, 31);
                        tempView.backgroundColor = [UIColor whiteColor];
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
                }
            }
        }
    }
    
    if(reloadBall){
        //if we are reloading a level that is in progress, we do not want to change the position of the ball
        self.ballX=0;
        self.ballY=1;
    }
    
    self.ballView = [[TheBall alloc] initWithFrame:CGRectMake(8+(30*self.ballX), 8+(30*(self.ballY/2)), 20, 20)];
    self.ballView.backgroundColor = [UIColor clearColor];
    
    [self.levelView addSubview:self.ballView];

   
    
}

-(UIView*)getDisappearingWallWithI:(int) i withJ:(int) j{
    UIView* tempView = [[UIView alloc] init];
    tempView.backgroundColor = [UIColor purpleColor];
    if(i%2==0){
        tempView.frame = CGRectMake(2+j*30, (i/2)*30, 31, 5);
    }else{
        tempView.frame = CGRectMake(j*30, 2+(i/2)*30, 5, 31);
    }
    return tempView;
}

-(UIView*)getOneWayWall1:(UIColor*) wallColor withI:(int) i withJ:(int) j{
    UIView* tempView = [[UIView alloc] init];
    UIColor* oneWayWallColor = [[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:.5];
    tempView.backgroundColor = oneWayWallColor;
    if(i%2==0){
        tempView.frame = CGRectMake(2+j*30, (i/2)*30, 31, 5);
        UIView* wallView = [[UIView alloc] initWithFrame:CGRectMake(0, 3, 31, 2)];
        wallView.backgroundColor = wallColor;
        [tempView addSubview:wallView];
    }else{
        tempView.frame = CGRectMake(j*30, 2+(i/2)*30, 5, 31);
        UIView* wallView = [[UIView alloc] initWithFrame:CGRectMake(3, 0, 2, 31)];
        wallView.backgroundColor = wallColor;
        [tempView addSubview:wallView];
    }
    
    return tempView;
}
-(UIView*)getOneWayWall2:(UIColor*) wallColor withI:(int) i withJ:(int) j{
    UIView* tempView = [[UIView alloc] init];
    UIColor* oneWayWallColor = [[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:.5];
    tempView.backgroundColor = oneWayWallColor;
    if(i%2==0){
        tempView.frame = CGRectMake(2+j*30, (i/2)*30, 31, 5);
        UIView* wallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 31, 2)];
        wallView.backgroundColor = wallColor;
        [tempView addSubview:wallView];
    }else{
        tempView.frame = CGRectMake(j*30, 2+(i/2)*30, 5, 31);
        UIView* wallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 31)];
        wallView.backgroundColor = wallColor;
        [tempView addSubview:wallView];
    }

    
    return tempView;
}



-(UIView*)getBounceWall1:(UIColor*) wallColor withI:(int) i withJ:(int) j{
    UIView*tempView = [[UIView alloc] init];
    tempView.backgroundColor = wallColor;
    if(i%2==0){
        tempView.frame = CGRectMake(2+j*30, (i/2)*30-1, 31, 6);
        UIView*bounceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 31, 3)];
        bounceView.backgroundColor = [UIColor whiteColor];
        [tempView addSubview:bounceView];
    }else{
        tempView.frame = CGRectMake(j*30-1, 2+(i/2)*30, 6, 31);
        UIView* bounceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, 31)];
        bounceView.backgroundColor = [UIColor whiteColor];
        [tempView addSubview:bounceView];
    }
    return tempView;
}

-(UIView*)getBounceWall2:(UIColor*) wallColor withI:(int) i withJ:(int) j{
    UIView*tempView = [[UIView alloc] init];
    tempView.backgroundColor = wallColor;
    if(i%2==0){
        tempView.frame = CGRectMake(2+j*30, (i/2)*30, 31, 6);
        UIView*bounceView = [[UIView alloc] initWithFrame:CGRectMake(0, 3, 31, 3)];
        bounceView.backgroundColor = [UIColor whiteColor];
        [tempView addSubview:bounceView];
    }else{
        tempView.frame = CGRectMake(j*30, 2+(i/2)*30, 6, 31);
        UIView* bounceView = [[UIView alloc] initWithFrame:CGRectMake(3, 0, 3, 31)];
        bounceView.backgroundColor = [UIColor whiteColor];
        [tempView addSubview:bounceView];
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
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    int currentLevel = [[defaults objectForKey:@"currentLevel"] intValue];
    currentLevel++;
    [defaults setObject:[NSNumber numberWithInt:currentLevel ] forKey:@"currentLevel"];
    
    [self.levelView removeFromSuperview];
    
    [self loadNextLevel];
    
}

-(void) restartLevel{
    [self.levelView removeFromSuperview];
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
    bool completedLevel = NO;
    bool lostLevel = NO;
    bool bounceBack = NO;
        bool needToReloadLevel = NO;
        
    NSLog(@"Swiped right");
    
    NSMutableArray* verticalWalls = self.levelArray[self.ballY];
    int firstWall=-1;
    for(int i=self.ballX+1; i<[verticalWalls count]; i++){
        if([verticalWalls[i] intValue]==1 || [verticalWalls[i] intValue] ==3 || [verticalWalls[i] intValue]==6 || [verticalWalls[i] intValue]==9){
            firstWall = i;
            break;
        }else if([verticalWalls[i] intValue]==2){
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
        }
    }
    NSLog(@"first wall at %i", firstWall);
    if(firstWall==-1){
        //that is, if there is no wall and the player has completed the level
        firstWall = 11;
        completedLevel =YES;
        // so that the ball will move out of the level
    }
    
    int travelDistance = 30*(firstWall-self.ballX-1);
    self.ballX= firstWall-1;
    //[UIView beginAnimations:@"ball" context:nil];
    //[UIView setAnimationDuration:1.0f];
    
    //float travelTime = travelDistance / ballSpeed;
    
    [UIView animateWithDuration:travelTime animations:^{
        self.ballView.frame = CGRectMake(self.ballView.frame.origin.x + travelDistance, self.ballView.frame.origin.y, 20, 20);
    }completion:^(BOOL finished){
        if(!bounceBack){
            _animating = NO;
        }
        if(completedLevel){
            [self finishedLevel];
        }if(lostLevel){
            [self restartLevel];
        }if(bounceBack){
            [self bounceBack:-1 onAxis:@"x"];
        }if(needToReloadLevel){
            [self reloadLevel];
        }
    }];
    }
}

- (IBAction)swipeLeft:(id)sender {
    if(!_animating){
        _animating = YES;
    
    bool completedLevel = NO;
    bool lostLevel = NO;
    bool bounceBack =NO;
    
    NSMutableArray* verticalWalls = self.levelArray[self.ballY];
    int firstWall = -1;
    for(int i=self.ballX; i>-1; i--){
        if([verticalWalls[i] intValue]==1 || [verticalWalls[i] intValue] ==2 || [verticalWalls[i] intValue]==5 || [verticalWalls[i] intValue]==8){
            firstWall = i;
            break;
        }else if([verticalWalls[i] intValue]==3){
            firstWall = i;
            lostLevel = YES;
            break;
        }else if([verticalWalls[i] intValue]==7 || [verticalWalls[i] intValue]==6){
            firstWall = i;
            bounceBack = YES;
            break;
        }
    }
    NSLog(@"first wall at %i", firstWall);
    if(firstWall==-1){
        firstWall = -1;
        completedLevel =YES;
    }
    int travelDistance = 30*(firstWall-self.ballX);
    self.ballX=firstWall;
        
        //float travelTime = -travelDistance / ballSpeed;
    
    [UIView animateWithDuration:travelTime animations:^{
        self.ballView.frame = CGRectMake(self.ballView.frame.origin.x + travelDistance, self.ballView.frame.origin.y, 20, 20);
    }completion:^(BOOL finished){
        if(!bounceBack){
            _animating = NO;
        }
        if(completedLevel){
            [self finishedLevel];
        }if(lostLevel){
            [self restartLevel];
        }if(bounceBack){
            [self bounceBack:1 onAxis:@"x"];
        }
    }];
    }
}

- (IBAction)swipeDown:(id)sender {
    if(!_animating){
        _animating = YES;
    bool completedLevel = NO;
    bool lostLevel = NO;
    bool bounceBack =NO;
    NSLog(@"Swiped down");
    int firstWall=-1;
    for(int i=_ballY+1; i<21; i=i+2){
        //we only want to look at the possible horizontal walls
        NSMutableArray* horizontalWalls = self.levelArray[i];
        if([horizontalWalls[_ballX] intValue]==1 || [horizontalWalls[_ballX] intValue]==3 || [horizontalWalls[_ballX] intValue]==6 ||[horizontalWalls[_ballX] intValue]==9){
            firstWall = i;
            break;
        }else if([horizontalWalls[_ballX] intValue]==2){
            //if the ball hits the spikey side of a wall
            firstWall = i;
            lostLevel = YES;
            break;
        }else if([horizontalWalls[_ballX] intValue]==7 || [horizontalWalls[_ballX] intValue]==5){
            firstWall =i;
            bounceBack =YES;
            break;
        }
    }
    if(firstWall==-1){
        firstWall = 22;
        completedLevel =YES;
    }
    
    int travelDistance = 30*((firstWall-self.ballY-1)/2);
    self.ballY=firstWall-1;
        
        //float travelTime = travelDistance / ballSpeed;

    [UIView animateWithDuration:travelTime animations:^{
        self.ballView.frame = CGRectMake(self.ballView.frame.origin.x , self.ballView.frame.origin.y+ travelDistance, 20, 20);;
    }completion:^(BOOL finished){
        if(!bounceBack){
            _animating = NO;
        }
        if(completedLevel){
            [self finishedLevel];
        }if(lostLevel){
            [self restartLevel];
        }if(bounceBack){
            [self bounceBack:-1 onAxis:@"y"];
        }
    }];
    }

}
- (IBAction)swipeUp:(id)sender {
    if(!_animating){
        _animating = YES;
    bool completedLevel = NO;
    bool lostLevel =NO;
    bool bounceBack = NO;
    NSLog(@"Swiped up");
    int firstWall=-1;
    for(int i=_ballY-1; i>-1; i=i-2){
        //we only want to look at the possible horizontal walls
        NSMutableArray* horizontalWalls = self.levelArray[i];
        if([horizontalWalls[_ballX] intValue]==1 || [horizontalWalls[_ballX] intValue]==2 || [horizontalWalls[_ballX] intValue]==5 || [horizontalWalls[_ballX] intValue]==8){
            firstWall = i;
            break;
        }else if([horizontalWalls[_ballX] intValue]==3){
            firstWall = i;
            lostLevel =YES;
            break;
        }else if([horizontalWalls[_ballX] intValue]==7 || [horizontalWalls[_ballX] intValue] ==6){
            firstWall =i;
            bounceBack = YES;
            break;
        }
    }
    if(firstWall==-1){
        firstWall = -2;
        completedLevel =YES;
    }
    int travelDistance = 30*((firstWall-self.ballY+1)/2);
    self.ballY=firstWall+1;
        //float travelTime = -travelDistance / ballSpeed;
    
    [UIView animateWithDuration:travelTime animations:^{
         self.ballView.frame = CGRectMake(self.ballView.frame.origin.x , self.ballView.frame.origin.y+ travelDistance, 20, 20);
    }completion:^(BOOL finished){
        if(!bounceBack){
            _animating = NO;
        }
        if(completedLevel){
            [self finishedLevel];
        }if(lostLevel){
            [self restartLevel];
        }if(bounceBack){
            [self bounceBack:1 onAxis:@"y"];
        }
    }];
    }
}

- (IBAction)backButton:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    int currentLevel = [[defaults objectForKey:@"currentLevel"] intValue];
    if(currentLevel>0){
        currentLevel--;
    
        [defaults setObject:[NSNumber numberWithInt:currentLevel ] forKey:@"currentLevel"];
        [self.levelView removeFromSuperview];
        [self loadNextLevel];
    }
    
}

- (IBAction)restartLevel:(id)sender {
    [self restartLevel];
}

-(void)reloadLevel{
    //this method will only reload the view of the level, it will not restart the level
    [self.levelView removeFromSuperview];
    [self drawCurrentLevelAndReloadBall:NO];
}

-(void)bounceBack:(int)direction onAxis:(NSString*)axis{
    if([axis isEqualToString:@"x"]){
        _ballX+=direction;
        [UIView animateWithDuration:.5 animations:^{
            self.ballView.frame = CGRectMake(self.ballView.frame.origin.x + direction*30, self.ballView.frame.origin.y, 20, 20);
        }completion:^(BOOL finished){
            _animating = NO;
        }
         ];
    }else if([axis isEqualToString:@"y"]){
        _ballY+=direction*2;
        [UIView animateWithDuration:.5 animations:^{
            self.ballView.frame = CGRectMake(self.ballView.frame.origin.x , self.ballView.frame.origin.y+ direction*30, 20, 20);
        }completion:^(BOOL finished){
            _animating = NO;
        }];

    }
}

@end
