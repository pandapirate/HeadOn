//
//  HelloWorldLayer.m
//  HeadOn
//
//  Created by Kevin Huang on 1/26/13.
//  Copyright The Company 2013. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "GameLayer.h"
#import "OnePlayerLayer.h"
#import "TwoPlayerLayer.h"
#import "SimpleAudioEngine.h"
#import "OnlinePlayerLayer.h"
#import "ProfileLayer.h"
#import "TutorialLayer.h"

#import "ResumeLayer.h"
#import <Parse/Parse.h>
#import "GameLogic.h"
#import "InvitationLayer.h"
#import "Reachability.h"
#import "Piece.h"
#import "GCHelper.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer
//@synthesize menuBar;
// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstTime"]){
            NSLog(@"First Time Launch");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstTime"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSound"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasMusic"];
            [[GCHelper sharedInstance] initializeStatistics];
        }
        
        // ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"cartoon bg1.png"];
        bg.position = ccp(size.width/2, size.height/2);
        [self addChild:bg];
        
        soundToggle = [CCMenuItemImage itemWithNormalImage:@"sound yes.png" selectedImage:@"sound no.png" target:self selector:@selector(toggleSound)];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSound"]){
            [soundToggle unselected];
        } else {
            [soundToggle selected];
        }
        
        musicToggle = [CCMenuItemImage itemWithNormalImage:@"music yes.png" selectedImage:@"music no.png" target:self selector:@selector(toggleMusic)];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasMusic"]){
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Hidden_Agenda.m4a" loop:YES];
            [musicToggle unselected];
        } else {
            [musicToggle selected];
        }
        soundToggle.scale = 0.90;
        soundToggle.position = ccp(95, 30);
        musicToggle.scale = 0.90;
        musicToggle.position = ccp(30, 30);
        
        CCMenuItem *tutorial = [CCMenuItemImage itemWithNormalImage:@"editquestion.png" selectedImage:@"editquestion.png" target:self selector:@selector(goToTutorial)];
        tutorial.position = ccp(size.width - 30, 30);
        tutorial.scale = 0.45;
        
        CCMenuItem *gamecenter = [CCMenuItemImage itemWithNormalImage:@"gamecenter.png" selectedImage:@"gamecenterdown.png" target:self selector:@selector(goToGamecenter)];
        gamecenter.position = ccp(size.width/2, 30);
        gamecenter.scale = 0.90;
        
        CCMenuItem *leaderboard = [CCMenuItemImage itemWithNormalImage:@"trophy.png" selectedImage:@"trophydown.png" target:self selector:@selector(goToLeaderboard)];
        leaderboard.position = ccp(size.width/2 + 65, 30);
        leaderboard.scale = 0.90;
        
        CCSprite *title = [CCSprite spriteWithFile:@"Title 500 x 300.png"];
        title.position = ccp( size.width /2 , size.height - 80);
        if (IS_IPHONE4) {
            title.position = ccp( size.width /2 , size.height - 60);
        }
        title.scale = 0.1;
        [self addChild: title];
        
        if (IS_IPHONE4)
            [title runAction:[CCScaleTo actionWithDuration:0.4 scale:1.0]];
        else
            [title runAction:[CCScaleTo actionWithDuration:0.4 scale:1.2]];
        
        int baseHeight = size.height - 180;
        int difference = 65;
        if (IS_IPHONE4) {
            baseHeight += 30;
            difference = 60;
        }
        
        play = [self createMenuItem:@"Play" atPosition:ccp(-size.width/2, baseHeight) withSelector:@selector(goToPlay)];
        resume = [self createMenuItem:@"Resume" atPosition:ccp(size.width*3/2, baseHeight - difference) withSelector:@selector(goToResume)];
        invitation = [self createMenuItem:@"Requests" atPosition:ccp(-size.width/2, baseHeight - 2*difference) withSelector:@selector(goToInvitation)];
        profile = [self createMenuItem:@"Profile" atPosition:ccp(size.width*3/2, baseHeight - 3*difference) withSelector:@selector(goToProfile)];
        
        CCMenu *startMenu = [CCMenu menuWithItems:play, resume, invitation, profile, soundToggle, musicToggle, tutorial, gamecenter, leaderboard, nil];
        startMenu.position = CGPointZero;
        [self addChild:startMenu z:5];
        
        [play runAction:[CCMoveTo actionWithDuration:0.4 position:ccp(size.width/2, play.position.y)]];
        [resume runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.4],[CCMoveTo actionWithDuration:0.4 position:ccp(size.width/2, resume.position.y)], nil]];
        [invitation runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8],[CCMoveTo actionWithDuration:0.4 position:ccp(size.width/2, invitation.position.y)], nil]];
        [profile runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.2],[CCMoveTo actionWithDuration:0.4 position:ccp(size.width/2, profile.position.y)], nil]];

        
        if (![GameLogic sharedGameLogic].naviBar)
            [[GameLogic sharedGameLogic] setUpNaviBar];
        
        if (![GameLogic sharedGameLogic].menuBar)
            [[GameLogic sharedGameLogic] setUpMenuBar];
        
        [[GameLogic sharedGameLogic] popViews];
        
        popupMenu = [[CCNode alloc] init];
        CGSize boardSize = CGSizeMake(300, 300);
        popupMenu.contentSize = boardSize;
        popupMenu.position = ccp(-500, size.height/2-135);
        if (IS_IPHONE4) {
            popupMenu.position = ccp(-500, size.height/2-150);
        }
        
        CCSprite *board = [CCSprite spriteWithFile:@"woodboard.png"];
        board.position = ccp(boardSize.width/2, boardSize.height/2);
        board.scaleX = 2.3;
        board.scaleY = 3.0;
        [popupMenu addChild:board z:0];
        
        CCLabelTTF *modeLabel = [CCLabelTTF labelWithString:@"Select Mode" fontName:@"Vanilla Whale" fontSize:45];
        modeLabel.position = ccp(boardSize.width/2, boardSize.height/2 + 100);
        modeLabel.color = ccc3(50, 25, 5);
        [popupMenu addChild:modeLabel z:2];
        
        CCMenuItem *onePlayer = [self createPopupMenuItem:   @"      Solo      " atPosition:ccp(boardSize.width/2, boardSize.height/2 + 52) withSelector:@selector(singlePlayer)];
        CCMenuItem *twoPlayer = [self createPopupMenuItem:   @"  Head to Head  " atPosition:ccp(boardSize.width/2, boardSize.height/2 + 1) withSelector:@selector(twoPlayer)];
        CCMenuItem *multiPlayer = [self createPopupMenuItem: @"   Multiplayer  " atPosition:ccp(boardSize.width/2, boardSize.height/2 - 51) withSelector:@selector(onlinePlay)];
        CCMenuItem *cancelPlayer = [self createPopupMenuItem:@"     Cancel     " atPosition:ccp(boardSize.width/2, boardSize.height/2 - 108) withSelector:@selector(cancelPopup)];
        
        CCMenu *popMenu = [CCMenu menuWithItems:onePlayer, twoPlayer, multiPlayer, cancelPlayer, nil];
        popMenu.position = CGPointZero;
        [popupMenu addChild:popMenu z:2];
        [self addChild:popupMenu z:10];
        
        
        tutorialMenu = [[CCNode alloc] init];
        tutorialMenu.contentSize = boardSize;
        tutorialMenu.position = ccp(1000, size.height/2-135);
        if (IS_IPHONE4) {
            tutorialMenu.position = ccp(1000, size.height/2-150);
        }
        
        CCSprite *tutBoard = [CCSprite spriteWithFile:@"woodboard.png"];
        tutBoard.position = ccp(boardSize.width/2, boardSize.height/2);
        tutBoard.scaleX = 2.3;
        tutBoard.scaleY = 3.0;
        [tutorialMenu addChild:tutBoard z:0];
        
        CCLabelTTF *tutLabel = [CCLabelTTF labelWithString:@"Tutorials" fontName:@"Vanilla Whale" fontSize:45];
        tutLabel.position = ccp(boardSize.width/2, boardSize.height/2 + 100);
        tutLabel.color = ccc3(50, 25, 5);
        [tutorialMenu addChild:tutLabel z:2];
        CCMenuItem *gameplayTut = [self createPopupMenuItem: @"       Gameplay       " atPosition:ccp(boardSize.width/2, boardSize.height/2 + 52) withSelector:@selector(gameplayTutorial)];
        CCMenuItem *onlineTut = [self createPopupMenuItem:@"      Multiplayer     " atPosition:ccp(boardSize.width/2, boardSize.height/2 + 1) withSelector:@selector(onlineTutorial)];
        CCMenuItem *otherTut = [self createPopupMenuItem: @"        Other         " atPosition:ccp(boardSize.width/2, boardSize.height/2 - 51) withSelector:@selector(otherTutorial)];
        CCMenuItem *cancelTut = [self createPopupMenuItem:@"        Cancel        " atPosition:ccp(boardSize.width/2, boardSize.height/2 - 108) withSelector:@selector(cancelTutorial)];
        
        CCMenu *tutMenu = [CCMenu menuWithItems:gameplayTut, onlineTut, otherTut, cancelTut, nil];
        tutMenu.position = CGPointZero;
        [tutorialMenu addChild:tutMenu z:2];
        [self addChild:tutorialMenu z:10];
        
        [self runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCDelayTime actionWithDuration:(arc4random() % 3 + 1)],[CCCallBlock actionWithBlock:^{
            [self addRandomWalker];
        }], nil]]];
	}
	return self;
}

- (CCMenuItem *) createMenuItem: (NSString *) text atPosition: (CGPoint) p withSelector: (SEL) sel{
    
    CCMenuItem *temp = [CCMenuItemImage itemWithNormalImage:@"log.png" selectedImage:@"log_selected.png" target:self selector:sel];
    temp.position = p;
    if (IS_IPHONE4)
        temp.scale = 0.9;
    
    CCLabelTTF *one = [CCLabelTTF labelWithString:text fontName:@"Vanilla Whale" fontSize:44];
    one.color = ccc3(35, 15, 0);
    one.position = ccp(temp.contentSize.width/2, temp.contentSize.height/2);
    [temp addChild:one];

    return temp;
}

- (CCMenuItem *) createPopupMenuItem: (NSString *) text atPosition: (CGPoint) p withSelector: (SEL) sel{
    CCLabelTTF *temp = [CCLabelTTF labelWithString:text fontName:@"Vanilla Whale" fontSize:42];
    temp.color = ccc3(50, 25, 5);
    CCMenuItem *tempMenu = [CCMenuItemLabel itemWithLabel:temp target:self selector:sel];
    tempMenu.position = p;
    
    return tempMenu;
}

- (void) toggleSound {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSound"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasSound"];
        [soundToggle selected];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSound"];
        [soundToggle unselected];
    }
}

- (void) toggleMusic {    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasMusic"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasMusic"];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [musicToggle selected];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasMusic"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Hidden_Agenda.m4a" loop:YES];
        [musicToggle unselected];
    }
}

- (void) singlePlayer{
    [[GameLogic sharedGameLogic] setTabBarSelection:-1];
    [[CCDirector sharedDirector] pushScene:[OnePlayerLayer scene]];
}

- (void) twoPlayer{
    [[GameLogic sharedGameLogic] setTabBarSelection:-1];
    [[CCDirector sharedDirector] pushScene:[TwoPlayerLayer scene]];
}

- (void) onlinePlay{
    if ([[GameLogic sharedGameLogic] networkReachable]) {
        [[GameLogic sharedGameLogic] setTabBarSelection:-1];
        [[CCDirector sharedDirector] pushScene:[OnlinePlayerLayer scene]];
    } else {
        UIAlertView *noInternet = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [noInternet show];
    }
}

- (void) cancelPopup {
    play.isEnabled = YES;
    resume.isEnabled = YES;
    invitation.isEnabled = YES;
    profile.isEnabled = YES;
    
    [popupMenu runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(-500, popupMenu.position.y)]];
}

- (void) gameplayTutorial {
    [[GameLogic sharedGameLogic] setTabBarSelection:-1];
    [[CCDirector sharedDirector] pushScene:[TutorialLayer sceneWithTutorial:1 exitTo:HOME]];
}

- (void) onlineTutorial {
    [[GameLogic sharedGameLogic] setTabBarSelection:-1];
    [[CCDirector sharedDirector] pushScene:[TutorialLayer sceneWithTutorial:2 exitTo:HOME]];
}

- (void) otherTutorial {
    [[GameLogic sharedGameLogic] setTabBarSelection:-1];
    [[CCDirector sharedDirector] pushScene:[TutorialLayer sceneWithTutorial:3 exitTo:HOME]];
}

- (void) cancelTutorial {
    play.isEnabled = YES;
    resume.isEnabled = YES;
    invitation.isEnabled = YES;
    profile.isEnabled = YES;
    
    [tutorialMenu runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(1000, popupMenu.position.y)]];
}

- (void) goToPlay {
    CGSize size = [[CCDirector sharedDirector] winSize];
    [popupMenu runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(size.width/2-150, popupMenu.position.y)]];
    play.isEnabled = NO;
    resume.isEnabled = NO;
    invitation.isEnabled = NO;
    profile.isEnabled = NO;
}

- (void) goToTutorial{
    CGSize size = [[CCDirector sharedDirector] winSize];
    [tutorialMenu runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(size.width/2-150, popupMenu.position.y)]];
    play.isEnabled = NO;
    resume.isEnabled = NO;
    invitation.isEnabled = NO;
    profile.isEnabled = NO;
}

- (void) goToProfile{
    [[GameLogic sharedGameLogic] setTabBarSelection:2];
    [[CCDirector sharedDirector] pushScene:[ProfileLayer scene]];
}

- (void) goToResume{
    [[GameLogic sharedGameLogic] setTabBarSelection:1];
    [[CCDirector sharedDirector] pushScene:[ResumeLayer scene]];
}

- (void) goToInvitation{
    if ([[GameLogic sharedGameLogic] networkReachable]) {
        [[GameLogic sharedGameLogic] setTabBarSelection:-1];
        [[CCDirector sharedDirector] pushScene:[InvitationLayer scene]];
    } else {
        UIAlertView *noInternet = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [noInternet show];

    }
}

- (void) goToGamecenter {
    GKAchievementViewController *achievementViewController = [[GKAchievementViewController alloc] init];
    achievementViewController.achievementDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    
    [[app navController] presentModalViewController:achievementViewController animated:YES];
}

- (void) goToLeaderboard {    
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    
    [[app navController] presentModalViewController:leaderboardViewController animated:YES];
    
}

- (void) addRandomWalker {
    int leftHeight = 160;
    int rightHeight = 100;
    
    if (IS_IPHONE4) {
        leftHeight -= 45;
        rightHeight -= 45;
    }
    
    int pieceNum = arc4random() % 10 + 1;
    
    Piece *piece = [[Piece alloc] init];
    CCNode *node = [piece createSprite:pieceNum];
    
    BOOL startLeft = (arc4random() % 2) == 1 ? NO : YES;
    
    if (startLeft)
        node.position = ccp(-160, leftHeight-45);
    else
        node.position = ccp(320, rightHeight-70);
    
    CGPoint dest = ccp(-160, leftHeight-35);
    if (startLeft)
        dest = ccp(320, rightHeight-85);
    
    node.scale = startLeft ? 0.6 : 1.0;
    
    [self addChild:node z:(startLeft ? 2 : 1)];
    
    int duration = arc4random() % 4 + 4;
    
    CCAction *move = [CCMoveTo actionWithDuration:duration position:dest];
    CCAction *scale = [CCScaleTo actionWithDuration:duration scale:(startLeft ? 1.0 : 0.6)];
    
    
    if (startLeft)
        [piece walkRight:15];
    else
        [piece walkLeft:15];
    
    [node runAction:move];
    [node runAction:scale];
    
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:duration],[CCCallBlock actionWithBlock:^{
        [self removeChild:node];
    }], nil]];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
