//
//  PuzzleLevelLayer.m
//  Head On
//
//  Created by Kevin Huang on 4/9/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import "PuzzleLevelLayer.h"
#import "PuzzleManager.h"
#import "PuzzleLayer.h"
#import "GameLayer.h"

@implementation PuzzleLevelLayer
+ (CCScene *) sceneWithWorld: (int) world {
    CCScene *scene = [CCScene node];
    PuzzleLevelLayer *layer = [[PuzzleLevelLayer alloc] initWithWorld: (int) world];
    [scene addChild:layer];
    return scene;
}

+ (CCScene *) sceneWithPage:(int)page {
    CCScene *scene = [CCScene node];
    
    int world = 0;
    switch (page) {
        case 4:
            world = 1;
            break;
        case 3:
            world = 2;
            break;
        case 2:
            world = 3;
            break;
        case 1:
            world = 4;
            break;
        default:
            break;
    }
    
    PuzzleLevelLayer *layer = [[PuzzleLevelLayer alloc] initWithWorld: (int) world];
    [scene addChild:layer];
    return scene;
}

- (id) initWithWorld: (int) number {
    if ((self = [super init])) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        world = number;
        
        CCSprite *bg;
        if (IS_IPHONE4)
            bg = [CCSprite spriteWithFile:@"bg-iphone4.png"];
        else
            bg = [CCSprite spriteWithFile:@"bg-iphone5.png"];
        
        bg.position = ccp(size.width/2, size.height/2);
        [self addChild:bg];
        
        
        [[GameLogic sharedGameLogic] showBars];
        
        NSString *worldName = @"";
        switch (world) {
            case 1:
                worldName = @"Sunny Meadow";
                break;
            case 2:
                worldName = @"Mysterious Forest";
                break;
            case 3:
                worldName = @"Brackish Wetlands";
                break;
            case 4:
                worldName = @"Barren Wasteland";
                break;
            default:
                break;
        }
        
        NSString *imageName = [NSString stringWithFormat:@"woodicon-%i.png", world];
        NSString *imageName2 = [NSString stringWithFormat:@"woodiconselected-%i.png", world];
        
        [[GameLogic sharedGameLogic] createBarItem:worldName];
        
        int startX = 60;
        int startY = 470;
        
        if (IS_IPHONE4) {
            startY = 395;
        }
        menuItems = [[NSMutableArray alloc] init];
        
        //populate the board
        for (int y = 0; y < 5; y++) {
            for (int x = 0; x < 3; x++) {
                CCMenuItem *item = [[CCMenuItemImage alloc] initWithNormalImage:imageName selectedImage:imageName2 disabledImage:nil target:self selector:@selector(goToLevel:)];
                item.scale = 2.7;
                item.tag = y * 3 + x + 1;
                item.position = ccp(startX + x*100, startY - y*77);
                
                if (IS_IPHONE4) {
                    item.scale = 2.2;
                    item.position = ccp(startX + x*100, startY - y*65);
                }
                
                [menuItems addObject:item];
                
                CCLabelTTF *LevelLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%i", item.tag] fontName:@"Vanilla Whale" fontSize:15];
                LevelLabel.position = ccp(item.contentSize.width/2, item.contentSize.height - 9);
                [item addChild:LevelLabel];
                
                if ([[PuzzleManager sharedPuzzleManager] isLevelEnabledForWorld:world AndLevel:item.tag]) {
                    int num = [[PuzzleManager sharedPuzzleManager] calculateStarsForWorld:world AndLevel:item.tag];
                    CCNode *stars = [[PuzzleManager sharedPuzzleManager] drawStars:num];
                    stars.position = ccp(0,0);
                    [item addChild:stars];
                } else {
                    item.isEnabled = NO;
                }
            }
        }
        
        CCMenu *menu = [[CCMenu alloc] initWithArray:menuItems];
        menu.position = CGPointZero;
        [self addChild:menu];
        
        [self setTouchEnabled:YES];
        
        CCLabelTTF *back = [CCLabelTTF labelWithString:@"Back" fontName:@"Vanilla Whale" fontSize:44];
        back.color = ccc3(0, 0, 0);
        CCMenuItem *backButton = [CCMenuItemImage itemWithNormalImage:@"log.png" selectedImage:@"log_selected.png" target:self selector:@selector(goBackToPuzzles)];
        backButton.scale = 0.7;
        back.position = ccp(backButton.contentSize.width/2, backButton.contentSize.height/2);
        [backButton addChild:back];
        backButton.position = ccp(70, size.height - 485);
        if (IS_IPHONE4) {
            backButton.scale = 0.6;
            backButton.position = ccp(70, size.height - 395);
        }
        
        CCMenu *startMenu = [CCMenu menuWithItems:backButton, nil];
        startMenu.position = CGPointZero;
        [self addChild:startMenu];

    }
    return self;
}

- (void) goToLevel: (CCMenuItem *) level {
    NSLog(@"%i", level.tag);
    
    NSString *name = [NSString stringWithFormat:@"%i-%i", world, level.tag];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:name];
    Puzzle *puzzle = (Puzzle *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    [[CCDirector sharedDirector] replaceScene:[GameLayer sceneFromPuzzle:puzzle]];
}

- (void) goBackToPuzzles {
    [[GameLogic sharedGameLogic] setTabBarSelection:-1];
    [[CCDirector sharedDirector] pushScene:[PuzzleLayer sceneWithPageNumber:world]];
}

@end
