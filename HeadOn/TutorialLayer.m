//
//  TutorialLayer.m
//  Head On
//
//  Created by Kevin Huang on 1/31/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import "TutorialLayer.h"
#import "GameLogic.h"
#import "Piece.h"

@implementation TutorialLayer
+ (CCScene *) sceneWithTutorial: (int) tutorialNumber exitTo: (int) exitNumber {
    CCScene *scene = [CCScene node];
    TutorialLayer *layer = [[TutorialLayer alloc] initWithTutorial:tutorialNumber exitTo:exitNumber];
    [scene addChild:layer];
    return scene;
}

- (id) initWithTutorial: (int) tutorialNumber exitTo: (int) exitNumber {
    if ((self = [super init])) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        [[GameLogic sharedGameLogic] showBars];
        if (IS_IPHONE4 && tutorialNumber == 1)
            [GameLogic sharedGameLogic].navBar.hidden = YES;
        
        // Set the background
        CCSprite *bg;
        
        if (IS_IPHONE4)
            bg = [CCSprite spriteWithFile:@"bg-iphone4.png"];
        else
            bg = [CCSprite spriteWithFile:@"bg-iphone5.png"];
        
        bg.position = ccp(size.width/2, size.height/2);
        [self addChild:bg];
        
        // Set the title
        switch (tutorialNumber) {
            case 1:
                [[GameLogic sharedGameLogic] createBarItem:@"Gameplay Tutorial"];
                [self createScroller:@"game" andNumber:9];
                break;
            case 2:
                [[GameLogic sharedGameLogic] createBarItem:@"Online Tutorial"];
                [self createScroller:@"online" andNumber:4];
                break;
            case 3:
                [[GameLogic sharedGameLogic] createBarItem:@"Other Tutorial"];
                [self createScroller:@"other" andNumber:3];
                break;
            default:
                break;
        }
    }
    return self;
}

- (void) createScroller: (NSString *) type andNumber: (int) num {
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    
    for (int i = 1; i <= num; i++) {
        CCLayer *layer = [[CCLayer alloc] init];
        NSString *imgName = @"";
        
        if (IS_IPHONE4) {
            imgName = [NSString stringWithFormat:@"%@-%i-4.jpg", type, i];
        } else {
            imgName = [NSString stringWithFormat:@"%@-%i.jpg", type, i];
        }
        
        CCSprite *tmp = [CCSprite spriteWithFile:imgName];
        
        if (!IS_IPHONE4)
            tmp.position = ccp(WINSIZE.width/2, WINSIZE.height/2 + 8);
        else {
            if ([type isEqualToString:@"game"])
                tmp.position = ccp(WINSIZE.width/2, WINSIZE.height/2 + 30);
            else
                tmp.position = ccp(WINSIZE.width/2, WINSIZE.height/2 + 8);
        }
        [layer addChild:tmp];
        
        [pages insertObject:layer atIndex:0];
    }
    
    pageScroll = [[CCScrollLayer alloc] initWithLayers:pages widthOffset:640];
    [pageScroll selectPage:num-1];
    pageScroll.showPagesIndicator = NO;
    [self addChild:pageScroll z:2];
}
@end
