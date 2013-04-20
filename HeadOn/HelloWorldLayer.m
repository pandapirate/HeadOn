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
#import "PuzzleLayer.h"
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
        
        // Stuff to do on every launch
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Launch"]) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Launch"];
                
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"NameSet"]) {
                UIAlertView *displayNameAlert = [[UIAlertView alloc] initWithTitle:@"New Display Name" message:@"Please enter preferred display name" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil, nil];
                displayNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *newNameField = [displayNameAlert textFieldAtIndex:0];
                newNameField.placeholder = @"New Display Name";
                displayNameAlert.tag = 1;
                [displayNameAlert show];
            }
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"toReview"]) {
                UIAlertView *commentAlert = [[UIAlertView alloc] initWithTitle:@"Like the app?" message:@"" delegate:self cancelButtonTitle:@"Never Review" otherButtonTitles:@"Rate Us", nil];
                [commentAlert addButtonWithTitle:@"Remind me later"];
                commentAlert.tag = 2;
                [commentAlert show];
            }
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"toReview"] == nil) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"toReview"];
            }
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
        
        puzzles = [self createMenuItem:@"Puzzles" atPosition:ccp(-size.width/2, baseHeight) withSelector:@selector(goToPuzzles)];
        play = [self createMenuItem:@"Classic" atPosition:ccp(size.width*3/2, baseHeight - difference) withSelector:@selector(goToPlay)];
        multiplayer = [self createMenuItem:@"Multiplayer" atPosition:ccp(-size.width/2, baseHeight - 2*difference) withSelector:@selector(goToMultiplayer)];
        profile = [self createMenuItem:@"Profile" atPosition:ccp(size.width*3/2, baseHeight - 3*difference) withSelector:@selector(goToProfile)];
        
        CCMenu *startMenu = [CCMenu menuWithItems:play, puzzles, multiplayer, profile, soundToggle, musicToggle, tutorial, gamecenter, leaderboard, nil];
        startMenu.position = CGPointZero;
        [self addChild:startMenu z:5];
        
        [puzzles runAction:[CCMoveTo actionWithDuration:0.4 position:ccp(size.width/2, puzzles.position.y)]];
        [play runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.4],[CCMoveTo actionWithDuration:0.4 position:ccp(size.width/2, play.position.y)], nil]];
        [multiplayer runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8],[CCMoveTo actionWithDuration:0.4 position:ccp(size.width/2, multiplayer.position.y)], nil]];
        [profile runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.2],[CCMoveTo actionWithDuration:0.4 position:ccp(size.width/2, profile.position.y)], nil]];

        
        if (![GameLogic sharedGameLogic].naviBar)
            [[GameLogic sharedGameLogic] setUpNaviBar];
        
        if (![GameLogic sharedGameLogic].menuBar)
            [[GameLogic sharedGameLogic] setUpMenuBar];
        
        [[GameLogic sharedGameLogic] popViews];
        
        classicMenu = [[CCNode alloc] init];
        CGSize boardSize = CGSizeMake(300, 300);
        classicMenu.contentSize = boardSize;
        classicMenu.position = ccp(-500, size.height/2-135);
        if (IS_IPHONE4) {
            classicMenu.position = ccp(-500, size.height/2-150);
        }
        
        // classic game board
        CCSprite *board = [CCSprite spriteWithFile:@"woodboard.png"];
        board.position = ccp(boardSize.width/2, boardSize.height/2);
        board.scaleX = 2.3;
        board.scaleY = 3.0;
        [classicMenu addChild:board z:0];
        
        CCLabelTTF *modeLabel = [CCLabelTTF labelWithString:@"Select Options" fontName:@"Vanilla Whale" fontSize:45];
        modeLabel.position = ccp(boardSize.width/2, boardSize.height/2 + 100);
        modeLabel.color = ccc3(50, 25, 5);
        [classicMenu addChild:modeLabel z:2];
        
        CCMenuItem *onePlayer = [self createPopupMenuItem:   @"      Solo      " atPosition:ccp(boardSize.width/2, boardSize.height/2 + 52) withSelector:@selector(singlePlayer)];
        CCMenuItem *twoPlayer = [self createPopupMenuItem:   @"   Head to Head   " atPosition:ccp(boardSize.width/2, boardSize.height/2 + 1) withSelector:@selector(twoPlayer)];
        CCMenuItem *multiPlayer = [self createPopupMenuItem: @"    Resume Saved    " atPosition:ccp(boardSize.width/2, boardSize.height/2 - 51) withSelector:@selector(goToResumeLocal)];
        CCMenuItem *cancelPlayer = [self createPopupMenuItem:@"     Cancel     " atPosition:ccp(boardSize.width/2, boardSize.height/2 - 108) withSelector:@selector(cancelPopup)];
        
        CCMenu *popMenu = [CCMenu menuWithItems:onePlayer, twoPlayer, multiPlayer, cancelPlayer, nil];
        popMenu.position = CGPointZero;
        [classicMenu addChild:popMenu z:2];
        [self addChild:classicMenu z:10];
        
        // Multiplayer Menu
        multiMenu = [[CCNode alloc] init];
        multiMenu.contentSize = boardSize;
        multiMenu.position = ccp(1000, size.height/2-135);
        if (IS_IPHONE4) {
            multiMenu.position = ccp(1000, size.height/2-150);
        }
        
        CCSprite *multBoard = [CCSprite spriteWithFile:@"woodboard.png"];
        multBoard.position = ccp(boardSize.width/2, boardSize.height/2);
        multBoard.scaleX = 2.3;
        multBoard.scaleY = 3.0;
        [multiMenu addChild:multBoard z:0];
        
        CCLabelTTF *multiLabel = [CCLabelTTF labelWithString:@"Select Options" fontName:@"Vanilla Whale" fontSize:45];
        multiLabel.position = ccp(boardSize.width/2, boardSize.height/2 + 100);
        multiLabel.color = ccc3(50, 25, 5);
        [multiMenu addChild:multiLabel z:2];                   
        CCMenuItem *findPlayers = [self createPopupMenuItem: @"   Find Players   " atPosition:ccp(boardSize.width/2, boardSize.height/2 + 52) withSelector:@selector(onlinePlay)];
        CCMenuItem *requests = [self createPopupMenuItem:@"   Game Requests   " atPosition:ccp(boardSize.width/2, boardSize.height/2 + 1) withSelector:@selector(goToInvitation)];
        CCMenuItem *resumeGame = [self createPopupMenuItem:@"    Resume Games    " atPosition:ccp(boardSize.width/2, boardSize.height/2 - 51) withSelector:@selector(goToResumeMulti)];
        CCMenuItem *cancelMult = [self createPopupMenuItem:@"     Cancel      " atPosition:ccp(boardSize.width/2, boardSize.height/2 - 108) withSelector:@selector(cancelMultiplayer)];
        
        CCMenu *mMenu = [CCMenu menuWithItems:findPlayers, requests, resumeGame, cancelMult, nil];
        mMenu.position = CGPointZero;
        [multiMenu addChild:mMenu z:2];
        [self addChild:multiMenu z:10];
        
        
        // Tutorial Menu
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
        
        CCLabelTTF *tutLabel = [CCLabelTTF labelWithString:@"Select Tutorial" fontName:@"Vanilla Whale" fontSize:45];
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
        
        
        // Random Walkers
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
    puzzles.isEnabled = YES;
    multiplayer.isEnabled = YES;
    profile.isEnabled = YES;
    
    [classicMenu runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(-500, classicMenu.position.y)]];
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
    puzzles.isEnabled = YES;
    multiplayer.isEnabled = YES;
    profile.isEnabled = YES;
    
    [tutorialMenu runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(1000, tutorialMenu.position.y)]];
}

- (void) cancelMultiplayer {
    play.isEnabled = YES;
    puzzles.isEnabled = YES;
    multiplayer.isEnabled = YES;
    profile.isEnabled = YES;
    
    [multiMenu runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(1000, multiMenu.position.y)]];
}

- (void) goToPuzzles {
    [[GameLogic sharedGameLogic] setTabBarSelection:-1];
    [[CCDirector sharedDirector] pushScene:[PuzzleLayer sceneWithPageNumber:1]];
}

- (void) goToPlay {
    CGSize size = [[CCDirector sharedDirector] winSize];
    [classicMenu runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(size.width/2-150, classicMenu.position.y)]];
    play.isEnabled = NO;
    puzzles.isEnabled = NO;
    multiplayer.isEnabled = NO;
    profile.isEnabled = NO;
}

- (void) goToTutorial{
    CGSize size = [[CCDirector sharedDirector] winSize];
    [tutorialMenu runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(size.width/2-150, tutorialMenu.position.y)]];
    play.isEnabled = NO;
    puzzles.isEnabled = NO;
    multiplayer.isEnabled = NO;
    profile.isEnabled = NO;
}

- (void) goToMultiplayer{
    CGSize size = [[CCDirector sharedDirector] winSize];
    [multiMenu runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(size.width/2-150, multiMenu.position.y)]];
    play.isEnabled = NO;
    puzzles.isEnabled = NO;
    multiplayer.isEnabled = NO;
    profile.isEnabled = NO;
}

- (void) goToProfile{
    [[GameLogic sharedGameLogic] setTabBarSelection:2];
    [[CCDirector sharedDirector] pushScene:[ProfileLayer scene]];
}

- (void) goToResumeLocal{
    [[GameLogic sharedGameLogic] setTabBarSelection:1];
    [[CCDirector sharedDirector] pushScene:[ResumeLayer sceneWithLocal:YES andMulti:NO]];
}

- (void) goToResumeMulti{
    [[GameLogic sharedGameLogic] setTabBarSelection:1];
    [[CCDirector sharedDirector] pushScene:[ResumeLayer sceneWithLocal:NO andMulti:YES]];
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

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1) {
        NSString *newName = [[alertView textFieldAtIndex:0] text];
        
        if (newName.length > 3) {
            PFObject *playerData = [GameLogic sharedGameLogic].playerData;
            [playerData setObject:newName forKey:@"DisplayName"];
            [playerData saveInBackground];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NameSet"];
        } else {
            UIAlertView *displayNameAlert = [[UIAlertView alloc] initWithTitle:@"New Display Name" message:@"Display name must have at least 4 characters" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil, nil];
            displayNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *newNameField = [displayNameAlert textFieldAtIndex:0];
            newNameField.placeholder = @"New Display Name";
            displayNameAlert.tag = 1;
            [displayNameAlert show];
        }
    }
    
    if (alertView.tag == 2) {
        switch (buttonIndex) {
            case 0: {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"toReview"];
                break;
            }
            case 1: {
                NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=598153431&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8"];
                [[UIApplication sharedApplication] openURL:url];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"toReview"];
                break;
            }
            default:
                break;
        }
    }
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
