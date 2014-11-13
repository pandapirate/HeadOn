//
//  PuzzleLayer.m
//  Head On
//
//  Created by Kevin Huang on 4/7/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import "PuzzleLayer.h"
#import "Puzzle.h"
#import "PuzzleManager.h"
#import "PuzzleLevelLayer.h"

@implementation PuzzleLayer

+ (CCScene *) sceneWithPageNumber:(int)page {
    CCScene *scene = [CCScene node];
    PuzzleLayer *layer = [[PuzzleLayer alloc] initWithPageNumber: page];
    [scene addChild:layer];
    return scene;
}

- (id) initWithPageNumber:(int) page {
    if ((self = [super init])) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *bg;
        if (IS_IPHONE4)
            bg = [CCSprite spriteWithFile:@"bg-iphone4.png"];
        else
            bg = [CCSprite spriteWithFile:@"bg-iphone5.png"];
        
        bg.position = ccp(size.width/2, size.height/2);
        [self addChild:bg];
        
        
        [[GameLogic sharedGameLogic] showBars];
        [[GameLogic sharedGameLogic] createBarItem:@"Select World"];

        NSMutableArray  *pages = [[NSMutableArray alloc] init];
        [pages addObject:[self createSpriteLayerForWorld:4]];
        [pages addObject:[self createSpriteLayerForWorld:3]];
        [pages addObject:[self createSpriteLayerForWorld:2]];
        [pages addObject:[self createSpriteLayerForWorld:1]];
        
        worldScroller = [[CCScrollLayer alloc] initWithLayers:pages widthOffset:700];
        worldScroller.showPagesIndicator = NO;
        worldScroller.stealTouches = NO;
        
        switch (page) {
            case 1:
                [worldScroller moveToPage:3];
                break;
            case 2:
                [worldScroller moveToPage:2];
                break;
            case 3:
                [worldScroller moveToPage:1];
                break;
            case 4:
                [worldScroller moveToPage:0];
                break;
            default:
                break;
        }
        
        [self addChild:worldScroller z:3];
        
        CCMenuItem *right = [[CCMenuItemImage alloc] initWithNormalImage:@"arrowup.png" selectedImage:@"arrowdown.png" disabledImage:nil target:self selector:@selector(shiftToRight)];
        CCMenuItem *left = [[CCMenuItemImage alloc] initWithNormalImage:@"arrowup.png" selectedImage:@"arrowdown.png" disabledImage:nil target:self selector:@selector(shiftToLeft)];
        left.rotation = 180;
        right.scale = 0.9;
        left.scale = 0.9;
        
        right.position = ccp(WINSIZE.width - 25, WINSIZE.height/2);
        left.position = ccp(25, WINSIZE.height/2);
        
        CCMenu *startMenu = [CCMenu menuWithItems:right, left, nil];
        startMenu.position = CGPointZero;
        [self addChild:startMenu z: 5];
        
        [self setTouchEnabled:YES];
    }
    return self;
}

- (void) shiftToRight {
    [worldScroller moveToPage:([worldScroller currentScreen]-1)];
}

- (void) shiftToLeft {
    [worldScroller moveToPage:([worldScroller currentScreen]+1)];
}

- (CCLayer *) createSpriteLayerForWorld: (int) number {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCLayer *layer = [[CCLayer alloc] init];
    NSString *num = [NSString stringWithFormat:@"World %i.png", number];
    
    CCSprite *bg = [[CCSprite alloc] initWithFile:num];
    bg.position = ccp(size.width/2, size.height/2);
    bg.scale = 1.75;
    [layer addChild:bg z:1];
    
    CCSprite *star = [[CCSprite alloc] initWithFile:@"star.png"];
    star.position = ccp(size.width/2, size.height - 205);
    star.scale = 0.85;
    [layer addChild:star z:1];
    
    int numStars = [[PuzzleManager sharedPuzzleManager] calculateStarsForWorld:number];
    int numPoints = [[PuzzleManager sharedPuzzleManager] calculatePointForWorld:number];
    int percentComplete = numStars * 100.0/45;
    
    NSString *StarLabel = [NSString stringWithFormat:@"%i/45", numStars];
    NSString *PointLabel = [NSString stringWithFormat:@"%i", numPoints];
    NSString *PercentLabel = [NSString stringWithFormat:@"%i%%", percentComplete];
    
    CCLabelTTF *stars = [CCLabelTTF labelWithString:StarLabel fontName:@"Vanilla Whale" fontSize:38];
    [stars setColor:ccc3(255, 255, 255)];
    stars.position = ccp(size.width/2, size.height - 245);
    [layer addChild:stars z:1];
    
    CCLabelTTF *completion = [CCLabelTTF labelWithString:PercentLabel fontName:@"Vanilla Whale" fontSize:38];
    [completion setColor:ccc3(255, 255, 255)];
    completion.position = ccp(size.width/2, size.height - 345);
    [layer addChild:completion z:1];
    
    CCLabelTTF *score = [CCLabelTTF labelWithString:PointLabel fontName:@"Vanilla Whale" fontSize:38];
    [score setColor:ccc3(255, 255, 255)];
    score.position = ccp(size.width/2, size.height - 445);
    [layer addChild:score z:1];
    
    if (![[PuzzleManager sharedPuzzleManager] isLevelEnabledForWorld:number AndLevel:1]) {
        [stars setString:@"World Locked"];
        [completion setString:@"World Locked"];
        [score setString:@"World Locked"];
    }
    
    if (IS_IPHONE4) {
        star.scale = 0.8;
        star.position = ccp(size.width/2, size.height - 175);
        bg.scale = 1.45;
        stars.position = ccp(size.width/2, size.height - 210);
        completion.position = ccp(size.width/2, size.height - 290);
        score.position = ccp(size.width/2, size.height - 370);
    }
    
    return layer;
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    beginningLocation = [self convertTouchToNodeSpace:touch];
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    int num = 0;
    
    switch (worldScroller.currentScreen) {
        case 3:
            num = 1;
            break;
        case 2:
            num = 2;
            break;
        case 1:
            num = 3;
            break;
        case 0:
            num = 4;
            break;
        default:
            break;
    }
    
    if (![[PuzzleManager sharedPuzzleManager] isLevelEnabledForWorld:num AndLevel:1]) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint finalLocation = [self convertTouchToNodeSpace:touch];
    
    CGRect start = CGRectMake(beginningLocation.x-20, beginningLocation.y-20, 40, 40);
    CGRect end = CGRectMake(finalLocation.x-20, finalLocation.y-20, 40, 40);

    if (CGRectIntersectsRect(start, end)) {
        [[CCDirector sharedDirector] replaceScene:[PuzzleLevelLayer sceneWithPage:(worldScroller.currentScreen+1)]];
    }
}

@end
