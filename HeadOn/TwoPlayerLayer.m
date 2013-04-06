//
//  TwoPlayerLayer.m
//  Head On
//
//  Created by Kevin Huang on 1/27/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import "TwoPlayerLayer.h"
#import "GameLayer.h"
#import "GameLogic.h"

@implementation TwoPlayerLayer
+ (CCScene *) scene {
    CCScene *scene = [CCScene node];
    TwoPlayerLayer *layer = [[TwoPlayerLayer alloc] init];
    [scene addChild:layer];
    return scene;
}

- (id) init {
    if ((self = [super initWithColor:ccc4(255, 255, 255, 255)])) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *bg;
        
        if (IS_IPHONE4)
            bg = [CCSprite spriteWithFile:@"bg-iphone4.png"];
        else
            bg = [CCSprite spriteWithFile:@"bg-iphone5.png"];
        
        bg.position = ccp(size.width/2, size.height/2);
        [self addChild:bg];
        
        [[GameLogic sharedGameLogic] showBars];
        
        [[GameLogic sharedGameLogic] createBarItem:@"Head to Head"];
		
        CCLabelTTF *label1 = [CCLabelTTF labelWithString:@"Player 1 Avatar" fontName:@"Vanilla Whale" fontSize:36];
		// position the label on the center of the screen
		label1.position =  ccp( size.width /2 , size.height - 65);
        label1.color = ccc3(0, 0, 0);
		// add the label as a child to this Layer
		[self addChild: label1];
        
        CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Player 2 Avatar" fontName:@"Vanilla Whale" fontSize:36];
		// position the label on the center of the screen
		label2.position =  ccp( size.width /2 , size.height - 215);
        label2.color = ccc3(0, 0, 0);
		// add the label as a child to this Layer
		[self addChild: label2];
        
        if (IS_IPHONE4) {
            label1.position =  ccp( size.width /2 , size.height - 60);
            label2.position =  ccp( size.width /2 , size.height - 175);
        }
        
        self.touchEnabled = YES;
        
        pieces1 = [[NSMutableArray alloc] init];
        pieces2 = [[NSMutableArray alloc] init];
        
        int scrollerHeight1 = size.height - 140;
        int scrollerHeight2 = size.height - 290;
        if (IS_IPHONE4) {
            scrollerHeight1 += 20;
            scrollerHeight2 += 50;
        }
        
        [self setUpScroller:scrollerHeight1 forPlayer1:YES];
        [self setUpScroller:scrollerHeight2 forPlayer1:NO];
        
        [player1Piece moveToPage:2];
        [player2Piece moveToPage:6];
        [[pieces1 objectAtIndex:2] jump:2];
        [[pieces2 objectAtIndex:6] jump:2];
        
        player1Piece.stealTouches = NO;
        player2Piece.stealTouches = NO;
                
        CCLabelTTF *start = [CCLabelTTF labelWithString:@"Start" fontName:@"Vanilla Whale" fontSize:44];
        start.color = ccc3(0, 0, 0);
        CCMenuItem *StartButton = [CCMenuItemImage itemWithNormalImage:@"log.png" selectedImage:@"log_selected.png" target:self selector:@selector(startGame)];
        start.position = ccp(StartButton.contentSize.width/2, StartButton.contentSize.height/2);
        [StartButton addChild:start];
        StartButton.position = ccp(size.width/2, size.height - 465);
        
        CCMenu *startMenu = [CCMenu menuWithItems:StartButton, nil];
        startMenu.position = CGPointZero;
        [self addChild:startMenu];
        
        UIFont *font = [UIFont fontWithName:@"Marker Felt" size:20];
        NSDictionary *controlSetting = [NSDictionary dictionaryWithObject:font forKey:UITextAttributeFont];
        
        NSArray *boards = [NSArray arrayWithObjects:@"4x4", @"5x5", @"6x6", nil];
        boardSizeControl = [[UISegmentedControl alloc] initWithItems:boards];
        [boardSizeControl setFrame:CGRectMake(10, 380, 300, 44)];
        [boardSizeControl setSelectedSegmentIndex:0];
        [boardSizeControl setTitleTextAttributes:controlSetting forState:UIControlStateNormal];
        [boardSizeControl setTitleTextAttributes:controlSetting forState:UIControlStateSelected];
        
        UIImage *segmentSelected =
        [[UIImage imageNamed:@"segcontrol_sel.png"]
         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
        UIImage *segmentUnselected =
        [[UIImage imageNamed:@"segcontrol_uns.png"]
         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
        UIImage *segmentSelectedUnselected =
        [UIImage imageNamed:@"segcontrol_sel-uns.png"];
        UIImage *segUnselectedSelected =
        [UIImage imageNamed:@"segcontrol_uns-sel.png"];
        UIImage *segmentUnselectedUnselected =
        [UIImage imageNamed:@"segcontrol_uns-uns.png"];
        
        [[UISegmentedControl appearance] setBackgroundImage:segmentUnselected
                                                   forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UISegmentedControl appearance] setBackgroundImage:segmentSelected
                                                   forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        [[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselected
                                     forLeftSegmentState:UIControlStateNormal
                                       rightSegmentState:UIControlStateNormal
                                              barMetrics:UIBarMetricsDefault];
        [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected
                                     forLeftSegmentState:UIControlStateSelected
                                       rightSegmentState:UIControlStateNormal
                                              barMetrics:UIBarMetricsDefault];
        [[UISegmentedControl appearance] setDividerImage:segUnselectedSelected forLeftSegmentState:UIControlStateNormal
                                       rightSegmentState:UIControlStateSelected
                                              barMetrics:UIBarMetricsDefault];
        
        [[[CCDirector sharedDirector] view] addSubview:boardSizeControl];
        
        CCLabelTTF *pickBoard = [CCLabelTTF labelWithString:@"Select Board Size" fontName:@"Vanilla Whale" fontSize:36];
		pickBoard.position =  ccp( size.width /2 , size.height - 360);
        pickBoard.color = ccc3(0, 0, 0);
		[self addChild: pickBoard];
        
        if (IS_IPHONE4) {
            pickBoard.position = ccp( size.width /2 , size.height - 300);
            [boardSizeControl setFrame:CGRectMake(40, 315, 240, 44)];
            StartButton.position = ccp(size.width/2, size.height - 390);
            StartButton.scale = 0.9;
            font = [UIFont fontWithName:@"Marker Felt" size:16];
        }
    }
    return self;
}

- (void) setUpScroller: (int) height forPlayer1: (BOOL) player1 {    
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    [pages addObject:[self createSpriteLayer:1 atHeight:height forPlayer1:player1]];
    [pages addObject:[self createSpriteLayer:2 atHeight:height forPlayer1:player1]];
    [pages addObject:[self createSpriteLayer:3 atHeight:height forPlayer1:player1]];
    [pages addObject:[self createSpriteLayer:4 atHeight:height forPlayer1:player1]];
    [pages addObject:[self createSpriteLayer:5 atHeight:height forPlayer1:player1]];
    [pages addObject:[self createSpriteLayer:6 atHeight:height forPlayer1:player1]];
    [pages addObject:[self createSpriteLayer:7 atHeight:height forPlayer1:player1]];
    [pages addObject:[self createSpriteLayer:8 atHeight:height forPlayer1:player1]];
    [pages addObject:[self createSpriteLayer:9 atHeight:height forPlayer1:player1]];
    [pages addObject:[self createSpriteLayer:10 atHeight:height forPlayer1:player1]];
    
    if (player1) {
        player1Piece = [[CCScrollLayer alloc] initWithLayers:pages widthOffset:500];
        player1Piece.showPagesIndicator = NO;
        [self addChild:player1Piece z:3];
    } else {
        player2Piece = [[CCScrollLayer alloc] initWithLayers:pages widthOffset:500];
        player2Piece.showPagesIndicator = NO;
        [self addChild:player2Piece z:3];
    }
}

- (CCLayer *) createSpriteLayer: (int) number atHeight: (int) height forPlayer1: (BOOL) player1{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCLayer *layer = [[CCLayer alloc] init];
    Piece *tempItem = [[Piece alloc] init];
    CCNode *node =[tempItem createSprite:number];
    node.position = ccp(size.width/2-68, height - 55);
    node.scale = 0.85;
    
    CCLabelTTF *name = [CCLabelTTF labelWithString:[[GameLogic sharedGameLogic] convertToFighter:number] fontName:@"Vanilla Whale" fontSize:28];
    [name setColor:ccc3(0, 0, 0)];
    name.position = ccp(size.width/2, height - 40);
    [layer addChild:name];
    [layer addChild:node];
    
    if (IS_IPHONE4) {
        node.position = ccp(size.width/2-60, height - 45);
        node.scale = 0.75;
        name.position = ccp(size.width/2, height - 30);
    }
    
    if (player1)
        [pieces1 addObject:tempItem];
    else
        [pieces2 addObject:tempItem];
    return layer;
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (IS_IPHONE4) {
        if (touchHeight > 195 && touchHeight < 285) {
            int index = player2Piece.currentScreen;
            [[pieces2 objectAtIndex:index] jump:2];
        }
        else if (touchHeight > 320 && touchHeight < 410) {
            int index = player1Piece.currentScreen;
            [[pieces1 objectAtIndex:index] jump:2];
        }
    } else {
        if (touchHeight > 240 && touchHeight < 335) {
            int index = player2Piece.currentScreen;
            [[pieces2 objectAtIndex:index] jump:2];
        }
        else if (touchHeight > 380 && touchHeight < 475) {
            int index = player1Piece.currentScreen;
            [[pieces1 objectAtIndex:index] jump:2];
        }
    }
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    NSLog(@"%f, %f", location.x, location.y);
    touchHeight = location.y;
    
    if (IS_IPHONE4) {
        if (touchHeight > 195 && touchHeight < 285) {
            player1Piece.stealTouches = NO;
            player2Piece.stealTouches = YES;
        }
        else if (touchHeight > 320 && touchHeight < 410) {
            player1Piece.stealTouches = YES;
            player2Piece.stealTouches = NO;
        }
        else {
            player1Piece.stealTouches = NO;
            player2Piece.stealTouches = NO;
        }
    } else {    
        if (touchHeight > 240 && touchHeight < 335) {
            player1Piece.stealTouches = NO;
            player2Piece.stealTouches = YES;
        }
        else if (touchHeight > 380 && touchHeight < 475) {
            player1Piece.stealTouches = YES;
            player2Piece.stealTouches = NO;
        }
        else {
            player1Piece.stealTouches = NO;
            player2Piece.stealTouches = NO;
        }
    }
}

- (void) returnToMenu {
    [[GameLogic sharedGameLogic] popViews];
    [[CCDirector sharedDirector] popScene];
}

- (void) startGame{
    if (player1Piece.currentScreen == player2Piece.currentScreen) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Avatars must be different" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    } else {
        NSLog(@"%i, %i", player1Piece.currentScreen, player2Piece.currentScreen);
        [[GameLogic sharedGameLogic] popViews];
        CCScene *gameScene = [GameLayer sceneWithPlayer1Sprite:player1Piece.currentScreen+1 andPlayer2Sprite:player2Piece.currentScreen+1 onBoard:(boardSizeControl.selectedSegmentIndex + 4)];
        [[CCDirector sharedDirector] replaceScene:gameScene];
    }
}

@end
