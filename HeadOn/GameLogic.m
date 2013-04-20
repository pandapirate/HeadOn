//
//  GameLogic.m
//  Head On
//
//  Created by Kevin Huang on 1/29/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import "GameLogic.h"
#import "HelloWorldLayer.h"
#import "ResumeLayer.h"
#import "ProfileLayer.h"
#import "GameLayer.h"

@implementation GameLogic
@synthesize menuBar, naviBar, menuBarItems, navBar;
static GameLogic *sharedGameLogic = nil;

+ (GameLogic*)sharedGameLogic {
    if (sharedGameLogic == nil) {
        sharedGameLogic = [[super allocWithZone:NULL] init];
    }
    return sharedGameLogic;
}


- (NSMutableArray *) checkCaptureOnBoard: (NSMutableArray *) board forPlayer: (BOOL) isPlayer1  atPosition: (Position *) position{
    NSMutableArray *capturedPieces = [[NSMutableArray alloc] init];
    
    int n = [board count];
    int p = isPlayer1 ? 1 : 2;
    int o = isPlayer1 ? 2 : 1;
    
    //x direction
    int own = -1;
    int opp = 0;
    BOOL hitOpp = NO;
    NSMutableArray *tempArray = [board objectAtIndex:position.boardY];
    NSMutableArray *tempCapture = [[NSMutableArray alloc] init];
    
    for (int i = position.boardX; i >= 0; i--){
//        NSLog(@"Left");
        Position *temp = [tempArray objectAtIndex:i];
        if (temp.piece == 0)
            break;
        else if (temp.piece == p && !hitOpp) {
            own += 1;
        } else if (temp.piece == o){
            hitOpp = YES;
            opp += 1;
            [tempCapture addObject:temp];
        }
    }
    
    hitOpp = NO;
    for (int i = position.boardX; i <= n-1; i++){
//        NSLog(@"Right");
        Position *temp = [tempArray objectAtIndex:i];
        if (temp.piece == 0)
            break;
        else if (temp.piece == p && !hitOpp) {
            own += 1;
        } else if (temp.piece == o){
            hitOpp = YES;
            opp += 1;
            [tempCapture addObject:temp];
        }
    }
//    NSLog(@"x : %i, %i", own, opp);
    
    if (own > opp) {
        [capturedPieces addObjectsFromArray:tempCapture];
    }
    
    //y direction
    own = -1;
    opp = 0;
    hitOpp = NO;
    tempCapture = [[NSMutableArray alloc] init];

    for (int i = position.boardY; i >= 0 ; i--) {
//        NSLog(@"Down");
        Position *temp = [[board objectAtIndex:i] objectAtIndex:position.boardX];
        if (temp.piece == 0)
            break;
        else if (temp.piece == p && !hitOpp) {
            own += 1;
        } else if (temp.piece == o){
            hitOpp = YES;
            opp += 1;
            [tempCapture addObject:temp];
        }
    }
    
    hitOpp = NO;
    for (int i = position.boardY; i <= n-1 ; i++) {
//        NSLog(@"Up");
        Position *temp = [[board objectAtIndex:i] objectAtIndex:position.boardX];
        if (temp.piece == 0)
            break;
        else if (temp.piece == p && !hitOpp) {
            own += 1;
        } else if (temp.piece == o){
            hitOpp = YES;
            opp += 1;
            [tempCapture addObject:temp];
        }
    }
//    NSLog(@"y : %i, %i", own, opp);
    
    if (own > opp) {
        [capturedPieces addObjectsFromArray:tempCapture];
    }
    
    NSLog(@"Captured Number: %i", [capturedPieces count]);
    return capturedPieces;
}

- (void) createBarItem: (NSString *) text {
    [navBar setText:text];
}

- (void) setUpNaviBar {
    UIFont *font = [UIFont fontWithName:@"Vanilla Whale" size:46];
    UIImage *bg = [[UIImage imageNamed:@"navbar-3.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    navBar = [[UILabel alloc] init];
    [navBar setFrame:CGRectMake(0, 0, 320, 44)];
    navBar.tag = 1337;
    [navBar setBackgroundColor:[UIColor colorWithPatternImage:bg]];
    [navBar setText:@"Title"];
    [navBar setFont:font];
    [navBar setTextColor:[UIColor colorWithRed:50./255 green:30./255 blue:5./255 alpha:1.0]];
    [navBar setTextAlignment:NSTextAlignmentCenter];
    navBar.hidden = YES;
    [[[CCDirector sharedDirector] view] addSubview:navBar];
}

- (void) setUpMenuBar {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    _HomeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, size.height-60, 107, 60)];
    _HomeButton.tag = 123;
    [_HomeButton addTarget:self action:@selector(goToHome) forControlEvents:UIControlEventTouchUpInside];
    [_HomeButton setImage:[UIImage imageNamed:@"homeup.png"] forState:UIControlStateNormal];
    [_HomeButton setImage:[UIImage imageNamed:@"homedown.png"] forState:UIControlStateSelected];
    
    _ResumeButton = [[UIButton alloc] initWithFrame:CGRectMake(107, size.height-60, 107, 60)];
    _ResumeButton.tag = 123;
    [_ResumeButton addTarget:self action:@selector(goToResume) forControlEvents:UIControlEventTouchUpInside];
    [_ResumeButton setImage:[UIImage imageNamed:@"resumeup.png"] forState:UIControlStateNormal];
    [_ResumeButton setImage:[UIImage imageNamed:@"resumedown.png"] forState:UIControlStateSelected];
    
    _ProfileButton = [[UIButton alloc] initWithFrame:CGRectMake(214, size.height-60, 107, 60)];
    _ProfileButton.tag = 123;
    [_ProfileButton addTarget:self action:@selector(goToProfile) forControlEvents:UIControlEventTouchUpInside];
    [_ProfileButton setImage:[UIImage imageNamed:@"profileup.png"] forState:UIControlStateNormal];
    [_ProfileButton setImage:[UIImage imageNamed:@"profiledown.png"] forState:UIControlStateSelected];
    
    [[[CCDirector sharedDirector] view] addSubview:_HomeButton];
    [[[CCDirector sharedDirector] view] addSubview:_ResumeButton];
    [[[CCDirector sharedDirector] view] addSubview:_ProfileButton];
}

- (void) goToHome {
    [self popViews];
    [naviBar popNavigationItemAnimated:NO];
    
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

- (void) goToResume {
    [self popViews];
    
    _ResumeButton.selected = YES;
    _ProfileButton.selected = NO;
    
    [[CCDirector sharedDirector] replaceScene:[ResumeLayer sceneWithLocal:YES andMulti:YES]];
}

- (void) goToProfile {
    [self popViews];
    
    _ProfileButton.selected = YES;
    _ResumeButton.selected = NO;
    
    [[CCDirector sharedDirector] replaceScene:[ProfileLayer scene]];
}

- (void) showBars {
    _HomeButton.hidden = NO;
    _ResumeButton.hidden = NO;
    _ProfileButton.hidden = NO;
    navBar.hidden = NO;
}

- (void) setTabBarSelection: (int) index {
    switch (index) {
        case -1: {
            _ProfileButton.selected = NO;
            _ResumeButton.selected = NO;
            break;
        } case 1: {
            _ProfileButton.selected = NO;
            _ResumeButton.selected = YES;
            break;
        } case 2: {
            _ProfileButton.selected = YES;
            _ResumeButton.selected = NO;
            break;
        }
        default:
            break;
    }
}

- (void) popViews {
    if ([[[[CCDirector sharedDirector] view] subviews] count] > 2) {
        for (UIView *x in [[[CCDirector sharedDirector] view] subviews]) {
            if (x.tag == 1337 || x.tag == 123)
                continue;
            [x removeFromSuperview];
        }
    }
    
    _HomeButton.hidden = YES;
    _ResumeButton.hidden = YES;
    _ProfileButton.hidden = YES;
    navBar.hidden = YES;
    
    [self setTabBarSelection:-1];
}

- (int) calculateLevel : (int) exp {
    double coef = log(exp/1093)/1.9483;
    int level = pow(10.0, coef);
    
    if (level < 0)
        return 0;
    else if (level > 50)
        return 50;
    else
        return level;
}

- (CCNode *) levelDisplay: (int) exp {
    int lvl = [self calculateLevel:exp];
    int suns = lvl/10;
    int moons = (lvl - 10 * suns)/5;
    int stars = lvl - 10 * suns - 5 * moons;
    NSLog(@"Level: %i, Suns: %i, Moons: %i, Stars: %i", lvl, suns, moons, stars);
    
    if (lvl == 0)
        stars = 1;
    
    CCNode *node = [[CCNode alloc] init];
    CGSize size = CGSizeMake(300, 40);
    node.contentSize = size;
    
    int x = 15;
    int y = 15;
    
    CCTexture2D *tex; 
    if (suns > 0) {
        tex = [[CCTextureCache sharedTextureCache] addImage:@"sun.png"];
        for (int i = 0; i < suns; i++) {
            CCSprite *s = [CCSprite spriteWithTexture:tex];
            s.scale = 0.6;
            s.position = ccp(x,y);
            [node addChild:s];
            x += 30;
        }
    }
    
    if (moons > 0) {
        tex = [[CCTextureCache sharedTextureCache] addImage:@"moon.png"];
        for (int i = 0; i < moons; i++) {
            CCSprite *s = [CCSprite spriteWithTexture:tex];
            s.scale = 0.6;
            s.position = ccp(x,y);
            [node addChild:s];
            x += 30;
        }
    }
    
    if (stars > 0) {
        tex = [[CCTextureCache sharedTextureCache] addImage:@"star.png"];
        for (int i = 0; i < stars; i++) {
            CCSprite *s = [CCSprite spriteWithTexture:tex];
            s.scale = 0.6;
            s.position = ccp(x,y);
            [node addChild:s];
            x += 30;
        }
    }
    
    return node;
}

- (BOOL) networkReachable {
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    
    return status != NotReachable;
}

- (NSString *) convertToFighter: (int) num {
    switch (num) {
        case 1:
            return @"Pooky";
        case 2:
            return @"Bamboo";
        case 3:
            return @"Momo";
        case 4:
            return @"Speedy";
        case 5:
            return @"Fuzzy";
        case 6:
            return @"Iggy";
        case 7:
            return @"Coco";
        case 8:
            return @"Lola";
        case 9:
            return @"Whiskers";
        case 10:
            return @"Fluffy";
        default:
            return @"Error";
    }
}


@end
