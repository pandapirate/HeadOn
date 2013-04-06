//
//  GameLogic.h
//  Head On
//
//  Created by Kevin Huang on 1/29/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#define IS_IPHONE4 (([[UIScreen mainScreen] bounds].size.height-568)?YES:NO)
#define HOME 0
#define SINGLEPLAYER 1
#define HEADTOHEAD 2
#define ONLINE 3
#define WINSIZE [[CCDirector sharedDirector] winSize]
#define CENTER ccp(WINSIZE.width/2, WINSIZE.height/2)

#import <Foundation/Foundation.h>
#import "Position.h"
#import "Reachability.h"
#import <Parse/Parse.h>
#import "cocos2d.h"

@interface GameLogic : NSObject <UITabBarDelegate>
+ (GameLogic*) sharedGameLogic;
- (NSMutableArray *) checkCaptureOnBoard: (NSMutableArray *) board forPlayer: (BOOL) isPlayer1 atPosition: (Position *) position;
- (void) setUpMenuBar;
- (void) setUpNaviBar;
- (void) popViews;
- (void) showBars;
- (void) createBarItem: (NSString *) text;
- (void) setTabBarSelection: (int) index;
- (int) calculateLevel : (int) exp;
- (BOOL) networkReachable;
- (NSString *) convertToFighter: (int) num;
- (CCNode *) levelDisplay: (int) exp;

@property (nonatomic, retain) UILabel *navBar;
@property (nonatomic) BOOL sound;
@property (nonatomic) BOOL music;
@property (nonatomic, retain) UINavigationBar *naviBar;
@property (nonatomic, retain) UITabBar *menuBar;
@property (nonatomic, retain) NSArray *menuBarItems;
@property (nonatomic, retain) UIButton *HomeButton;
@property (nonatomic, retain) UIButton *ResumeButton;
@property (nonatomic, retain) UIButton *ProfileButton;
@property (nonatomic, retain) PFObject *playerData;
@end
