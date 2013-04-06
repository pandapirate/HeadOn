//
//  OnePlayerLayer.m
//  Head On
//
//  Created by Kevin Huang on 1/27/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import "OnePlayerLayer.h"
#import "GameLayer.h"
#import "HelloWorldLayer.h"
#import "GameLogic.h"
#import "Piece.h"

@implementation OnePlayerLayer

+ (CCScene *) scene {
    CCScene *scene = [CCScene node];
    OnePlayerLayer *layer = [[OnePlayerLayer alloc] init];
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

        self.touchEnabled = YES;
        
        [[GameLogic sharedGameLogic] showBars];
        
        [[GameLogic sharedGameLogic] createBarItem:@"Solo"];
        
        NSArray *difficulties = [NSArray arrayWithObjects:@"Rookie", @"Regular", @"Veteran", @"Master", nil];
        
        difficultyControl = [[UISegmentedControl alloc] initWithItems:difficulties];
        [difficultyControl setFrame:CGRectMake(10, 275, 300, 44)];
        if (IS_IPHONE4) {
           [difficultyControl setFrame:CGRectMake(10, 225, 300, 44)];
        }
        [difficultyControl setSelectedSegmentIndex:0];
        
        UIFont *font = [UIFont fontWithName:@"Marker Felt" size:15];
        NSDictionary *controlSetting = [NSDictionary dictionaryWithObject:font forKey:UITextAttributeFont];
        [difficultyControl setTitleTextAttributes:controlSetting forState:UIControlStateNormal];
        [difficultyControl setTitleTextAttributes:controlSetting forState:UIControlStateSelected];
        
        NSArray *boards = [NSArray arrayWithObjects:@"4x4", @"5x5", @"6x6", nil];
        boardSizeControl = [[UISegmentedControl alloc] initWithItems:boards];
        [boardSizeControl setFrame:CGRectMake(10, 380, 300, 44)];
        if (IS_IPHONE4) {
            [boardSizeControl setFrame:CGRectMake(10, 310, 300, 44)];
        }
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
        
        [[[CCDirector sharedDirector] view] addSubview:difficultyControl];
        [[[CCDirector sharedDirector] view] addSubview:boardSizeControl];
        
        CCLabelTTF *start = [CCLabelTTF labelWithString:@"Start" fontName:@"Vanilla Whale" fontSize:44];
        start.color = ccc3(0, 0, 0);
        CCMenuItem *StartButton = [CCMenuItemImage itemWithNormalImage:@"log.png" selectedImage:@"log_selected.png" target:self selector:@selector(start)];
        start.position = ccp(StartButton.contentSize.width/2, StartButton.contentSize.height/2);
        [StartButton addChild:start];
        StartButton.position = ccp(size.width/2, size.height - 465);
        if (IS_IPHONE4) {
            StartButton.position = ccp(size.width/2, size.height - 390);
        }
        
        CCMenu *startMenu = [CCMenu menuWithItems:StartButton, nil];
        startMenu.position = CGPointZero;
        [self addChild:startMenu];
        
        NSMutableArray  *pages = [[NSMutableArray alloc] init];
        pieces = [[NSMutableArray alloc] init];
        [pages addObject:[self createSpriteLayer:1]];
        [pages addObject:[self createSpriteLayer:2]];
        [pages addObject:[self createSpriteLayer:3]];
        [pages addObject:[self createSpriteLayer:4]];
        [pages addObject:[self createSpriteLayer:5]];
        [pages addObject:[self createSpriteLayer:6]];
        [pages addObject:[self createSpriteLayer:7]];
        [pages addObject:[self createSpriteLayer:8]];
        [pages addObject:[self createSpriteLayer:9]];
        [pages addObject:[self createSpriteLayer:10]];
        
        avatarScroll = [[CCScrollLayer alloc] initWithLayers:pages widthOffset:500];
        avatarScroll.showPagesIndicator = NO;
        avatarScroll.stealTouches = NO;
        [avatarScroll moveToPage:6];
        [[pieces objectAtIndex:6] jump:2];
        [self addChild:avatarScroll z:3];
        
        int fontsize = 40;
        if (IS_IPHONE4) {
            fontsize = 36;
        }
        
        CCLabelTTF *pickAvatar = [CCLabelTTF labelWithString:@"Select Avatar" fontName:@"Vanilla Whale" fontSize:fontsize];
		pickAvatar.position =  ccp( size.width /2 , size.height - 70);
        pickAvatar.color = ccc3(0, 0, 0);
		[self addChild: pickAvatar];
        
        CCLabelTTF *pickLevel = [CCLabelTTF labelWithString:@"Select Difficulty" fontName:@"Vanilla Whale" fontSize:fontsize];
		pickLevel.position =  ccp( size.width /2 , size.height - 250);
        pickLevel.color = ccc3(0, 0, 0);
		[self addChild: pickLevel];
        
        CCLabelTTF *pickBoard = [CCLabelTTF labelWithString:@"Select Board Size" fontName:@"Vanilla Whale" fontSize:fontsize];
		pickBoard.position =  ccp( size.width /2 , size.height - 350);
        pickBoard.color = ccc3(0, 0, 0);
		[self addChild: pickBoard];
        
        if (IS_IPHONE4) {
            pickAvatar.position =  ccp( size.width /2 , size.height - 65);
            pickLevel.position =  ccp( size.width /2 , size.height - 210);
            pickBoard.position =  ccp( size.width /2 , size.height - 290);
        }
    }
    return self;
}

- (CCLayer *) createSpriteLayer: (int) number {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCLayer *layer = [[CCLayer alloc] init];
    Piece *tempItem = [[Piece alloc] init];
    CCNode *node =[tempItem createSprite:number];
    node.position = ccp(size.width/2-80, size.height - 225);
    if (IS_IPHONE4) {
        node.position = ccp(size.width/2-72, size.height - 200);
        node.scale = 0.9;
    }
    
    [layer addChild:node];
    
    CCLabelTTF *name = [CCLabelTTF labelWithString:[[GameLogic sharedGameLogic] convertToFighter:number] fontName:@"Vanilla Whale" fontSize:32];
    [name setColor:ccc3(0, 0, 0)];
    name.position = ccp(size.width/2, size.height - 210);
    if (IS_IPHONE4) {
       name.position = ccp(size.width/2, size.height - 180);
    }
    [layer addChild:name];
    [pieces addObject:tempItem];
    
    return layer;
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    NSLog(@"%f, %f", location.x, location.y);
    touchHeight = location.y;
    
    if (IS_IPHONE4) {
        if (touchHeight > 290 && touchHeight < 400) {
            avatarScroll.stealTouches = YES;
        } else {
            avatarScroll.stealTouches = NO;
        }
    } else {    
        if (touchHeight > 340 && touchHeight < 450) {
            avatarScroll.stealTouches = YES;
        } else {
            avatarScroll.stealTouches = NO;
        }
    }

}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (IS_IPHONE4) {
        if (touchHeight > 290 && touchHeight < 400) {
            int index = avatarScroll.currentScreen;
            [[pieces objectAtIndex:index] jump:2];
        }
    } else {
        if (touchHeight > 340 && touchHeight < 450) {
            int index = avatarScroll.currentScreen;
            [[pieces objectAtIndex:index] jump:2];
        }
    }
}

- (void) returnToMenu {
    [[GameLogic sharedGameLogic] popViews];
    [[CCDirector sharedDirector] popScene];
}

- (void) start{
    NSLog(@"%i", difficultyControl.selectedSegmentIndex);
    
    [[GameLogic sharedGameLogic] popViews];
    CCScene *gameScene = [GameLayer sceneWithDifficulty:difficultyControl.selectedSegmentIndex + 2 andSprite:avatarScroll.currentScreen+1 onBoard: (boardSizeControl.selectedSegmentIndex + 4)];
    [[CCDirector sharedDirector] replaceScene:gameScene];
}

@end
