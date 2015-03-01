//
//  BRLevelSelectViewController.m
//  Amaze Ball
//
//  Created by John Karabinos on 1/24/15.
//  Copyright (c) 2015 John Karabinos. All rights reserved.
//

#import "BRLevelSelectViewController.h"
#import "BRViewController.h"
#import "LevelSelectView.h"
#import <AVFoundation/AVFoundation.h>

@interface BRLevelSelectViewController ()

@property (strong, nonatomic) UIPickerView* levelPicker;

@property (strong, nonatomic) AVAudioPlayer *amazeSound;

@property (nonatomic) bool animating;

@property (strong, nonatomic) NSArray* levelPacks;
@property (nonatomic) int currentPack;

@property (strong, nonatomic) NSMutableArray* levelSelectViews;

@property (strong, nonatomic) UIView* blackStartView;

@end

@implementation BRLevelSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self addPickerView];
    _animating = NO;
    
    
    
    /*self.levelView = [self addLevelButtons];
    [self.view addSubview:self.levelView];*/
    
    /*NSString *pewPewPath = [[NSBundle mainBundle]
                            pathForResource:@"pew-pew-lei" ofType:@"caf"];
    NSURL *pewPewURL = [NSURL fileURLWithPath:pewPewPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &self.pewPewSound);
    AudioServicesPlaySystemSound(self.pewPewSound);*/
    
    NSString *path = [NSString stringWithFormat:@"%@/AMAZE BALL.wav", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    // Create audio player object and initialize with URL to sound
    _amazeSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    
    
    UIImageView* tempImageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lp1"]];
    UIImageView* tempImageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lp2"]];
    UIImageView* tempImageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lp3"]];
    UIImageView* tempImageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lp4"]];
    
    self.levelPacks = [[NSArray alloc] initWithObjects:tempImageView1,tempImageView2,tempImageView3,tempImageView4, nil];
    _currentPack = 0;
    
    //in order to fix a bug with the original image view we will create and add one to the level pack super view
    UIImageView* tempImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lp1"]];
    tempImage.frame = self.levelPackImageView.frame;
    [self.levelPackImageView removeFromSuperview];
    [self.levelPackView addSubview:tempImage];
    self.levelPackImageView = tempImage;
    
    
    
    self.levelSelectViews = [[NSMutableArray alloc] init];
    //we will initialize all of the level select views as soon as the
    // view loads and then grab them from the array as need be later on
    for(int i=0; i<4; i++){
        //we will need to change this number as the number of level packs increases
        
        UIView* levelSelectView = [self addLevelButtonsForPack:i];
        [self.levelSelectViews addObject:levelSelectView];
        levelSelectView.alpha = 0;
        [self.view addSubview:levelSelectView];
    }
    UIView* currentLevelView = self.levelSelectViews[0];
    currentLevelView.alpha=1;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.blackStartView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2000, 2000)];
    self.blackStartView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.blackStartView];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [UIView animateWithDuration:.25 animations:^{
        self.blackStartView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.blackStartView removeFromSuperview];
    }];
    
    //[self.amazeSound play];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*-(void)addPickerView{
    self.levelPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(80, 200, 160, 400)];
    self.levelPicker.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.levelPicker.delegate = self;
    self.levelPicker.dataSource = self;
    
    [self.view addSubview:self.levelPicker];
    
}*/

-(UIView*)addLevelButtonsForPack:(int) pack{
    /*if(!fade){
        [self.levelView removeFromSuperview];
    }else {
        self.tempLevelView = self.levelView;
    }*/
    UIView* tempView =[[UIView alloc] initWithFrame:CGRectMake(10, 160, 300, 300)];
    
    //self.levelView = [[UIView alloc] initWithFrame:CGRectMake(10, 160, 300, 300)];
    for(int i=0; i<25; i++){
        LevelSelectView* lsv = [LevelSelectView lsv];
        lsv.frame = CGRectMake((i%5)*60, (i/5)*60, lsv.frame.size.width, lsv.frame.size.height);
        lsv.tag = i+[self.levelPicker selectedRowInComponent:0]*25;
        lsv.numberLabel.text = [@(i+1) stringValue];
        lsv.parentViewController = (BRLevelSelectViewController*)self;
        [self configureLsv:lsv withLevel:i andPack:pack];
    
        [tempView addSubview:lsv];
    }/*
    if(fade){
        self.levelView.alpha = 0;
        [self.view addSubview:self.levelView];
        [UIView animateWithDuration:1.0 animations:^{
            self.levelView.alpha = 1;
            self.tempLevelView.alpha = 0;
        } completion:^(BOOL finished) {
            NSLog(@"donesoes");
            [self.tempLevelView removeFromSuperview];
        }];
    }else {
        [self.view addSubview:self.levelView];
    }*/
    
    return tempView;
}

-(void)configureLsv:(LevelSelectView*) lsv withLevel:(int) i andPack:(int) pack{

    int playableLevel = [[[NSUserDefaults standardUserDefaults] objectForKey:@"playableLevel"] intValue];
    
    int currentLevel = i + pack*25;
    
    
    if(pack==0){
        //if the user cannot play the level we want to shade it darker and hide the number label
        if(currentLevel<=playableLevel){
            [lsv.selectButton setImage:[UIImage imageNamed:@"l2"] forState:UIControlStateNormal];
        }else{
            [lsv.selectButton setImage:[UIImage imageNamed:@"l2d"] forState:UIControlStateNormal];
            lsv.numberLabel.hidden = YES;
            //lsv.selectButton.userInteractionEnabled = NO;
        }
    }else if(pack==1){
        if(currentLevel<=playableLevel){
            [lsv.selectButton setImage:[UIImage imageNamed:@"l3"] forState:UIControlStateNormal];
        }else{
            [lsv.selectButton setImage:[UIImage imageNamed:@"l3d"] forState:UIControlStateNormal];
            lsv.numberLabel.hidden = YES;
            //lsv.selectButton.userInteractionEnabled = NO;
        }
    }else if(pack==2){
        if(currentLevel<=playableLevel){
            [lsv.selectButton setImage:[UIImage imageNamed:@"l4"] forState:UIControlStateNormal];
        }else{
            [lsv.selectButton setImage:[UIImage imageNamed:@"l4d"] forState:UIControlStateNormal];
            lsv.numberLabel.hidden = YES;
            //lsv.selectButton.userInteractionEnabled = NO;
        }
    }else if(pack==3){
        if(currentLevel<=playableLevel){
            [lsv.selectButton setImage:[UIImage imageNamed:@"l6"] forState:UIControlStateNormal];
        }else{
            [lsv.selectButton setImage:[UIImage imageNamed:@"l6d"] forState:UIControlStateNormal];
            lsv.numberLabel.hidden = YES;
            //lsv.selectButton.userInteractionEnabled = NO;
        }
    }
}

-(void)loadLevel:(UIView*)sender{
    //set the current level
    int currentLevel = (int)[sender tag];
    currentLevel = (_currentPack*25)+currentLevel;
    NSArray* levels = [[NSUserDefaults standardUserDefaults] objectForKey:@"levels"];
    int numberOfLevels = (int)[levels count];
    if(currentLevel<numberOfLevels){
    
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currentLevel] forKey:@"currentLevel"];
        //then load the level view controller
        //UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
        //BRViewController *controller = (BRViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"level"];
    
        
        
        
        self.blackStartView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2000, 2000)];
        self.blackStartView.backgroundColor = [UIColor blackColor];
        self.blackStartView.alpha = 0;
        [self.view addSubview:self.blackStartView];

        [UIView animateWithDuration:.25 animations:^{
            self.blackStartView.alpha = 1;
        } completion:^(BOOL finished) {
            [self removeAllSubviews];
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
        
        //[self presentViewController:controller animated:NO completion:nil];
    }
}

-(void)removeAllSubviews{
    NSArray* tempSubviews = self.view.subviews;
    for(int i=0; i< [tempSubviews count]; i++){
        UIView* tempSubview = tempSubviews[i];
        [tempSubview removeFromSuperview];
    }
}

- (IBAction)moveLeft:(id)sender {
    if(!_animating){
        if(_currentPack-1>=0){
            _currentPack--;
            //NSString* levelName = self.levelPacks[_currentPack];
            _animating = YES;
            NSLog(@"select level pack to the left");
            UIImageView* newPack = self.levelPacks[_currentPack];
            newPack.frame = CGRectMake(self.levelPackImageView.frame.origin.x-160, self.levelPackImageView.frame.origin.y, self.levelPackImageView.frame.size.width, self.levelPackImageView.frame.size.height);
    
            newPack.alpha = 0;
    
            [self.levelPackView addSubview:newPack];
            
            /*
            self.tempLevelView = self.levelView;
            //self.levelView = [self addLevelButtons];
            self.levelView.alpha = 0;
            [self.view addSubview:self.levelView];*/
    
            [UIView animateWithDuration:.5 animations:^{
                newPack.frame = CGRectMake(newPack.frame.origin.x+160, newPack.frame.origin.y, newPack.frame.size.width, newPack.frame.size.height);
                self.levelPackImageView.frame = CGRectMake(self.levelPackImageView.frame.origin.x+160, self.levelPackImageView.frame.origin.y, self.levelPackImageView.frame.size.width, self.levelPackImageView.frame.size.height);
                newPack.alpha =1;
                self.levelPackImageView.alpha = 0;
                
                UIView* oldView = self.levelSelectViews[_currentPack+1];
                UIView* newView = self.levelSelectViews[_currentPack];
                oldView.alpha = 0;
                newView.alpha = 1;
                
                //self.levelView.alpha = 1;
                //self.tempLevelView.alpha = 0;
        
            } completion:^(BOOL finished) {
                NSLog(@"done");
                [self.levelPackImageView removeFromSuperview];
                self.levelPackImageView = newPack;
                _animating = NO;
                //[self.tempLevelView removeFromSuperview];
            }];
        }
    }
}

- (IBAction)moveRight:(id)sender {
    if(!_animating){
        if([self.levelPacks count]>_currentPack+1){
            _animating = YES;
            NSLog(@"select level pack to the right");
            _currentPack++;
            //NSString* levelName = self.levelPacks[_currentPack];
            UIImageView* newPack = self.levelPacks[_currentPack];
            newPack.frame = CGRectMake(self.levelPackImageView.frame.origin.x+160, self.levelPackImageView.frame.origin.y, self.levelPackImageView.frame.size.width, self.levelPackImageView.frame.size.height);

            newPack.alpha = 0;
    
            [self.levelPackView addSubview:newPack];
    
            /*
            self.tempLevelView = self.levelView;
            self.levelView = [self addLevelButtons];
            self.levelView.alpha = 0;
            [self.view addSubview:self.levelView];*/
            
            [UIView animateWithDuration:.5 animations:^{
                newPack.frame = CGRectMake(newPack.frame.origin.x-160, newPack.frame.origin.y, newPack.frame.size.width, newPack.frame.size.height);
                self.levelPackImageView.frame = CGRectMake(self.levelPackImageView.frame.origin.x-160, self.levelPackImageView.frame.origin.y, self.levelPackImageView.frame.size.width, self.levelPackImageView.frame.size.height);
                newPack.alpha =1;
                self.levelPackImageView.alpha = 0;
                
                UIView* oldView = self.levelSelectViews[_currentPack-1];
                UIView* newView = self.levelSelectViews[_currentPack];
                oldView.alpha = 0;
                newView.alpha = 1;
                
                
                //self.levelView.alpha=1;
                //self.tempLevelView.alpha = 0;
        
            } completion:^(BOOL finished) {
                NSLog(@"done");
                [self.levelPackImageView removeFromSuperview];
                self.levelPackImageView = newPack;
                _animating = NO;
                //[self.tempLevelView removeFromSuperview];
            }];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
