//
//  OnlineGameSelection.m
//  Head On
//
//  Created by Kevin Huang on 2/12/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import "OnlineGameSelection.h"
#import "Game.h"
#import "OnlinePlayerLayer.h"
#import "GameLayer.h"

@implementation OnlineGameSelection

+ (CCScene *) sceneWithPlayer: (PFObject *) user{
    CCScene *scene = [CCScene node];
    OnlineGameSelection *layer = [[OnlineGameSelection alloc] initWithUser:user];
    [scene addChild:layer];
    return scene;
}

+ (CCScene *) sceneWithGame:(PFObject *)game {
    CCScene *scene = [CCScene node];
    OnlineGameSelection *layer = [[OnlineGameSelection alloc] initWithGame:game];
    [scene addChild:layer];
    return scene;
}

- (id) initWithGame: (PFObject *) game { 
    if ((self = [super init])) {
        opponent = [game objectForKey:@"Player1"];
        startedGame = NO;
        
        GameObject = game;
        NSData *encodedGame = [game objectForKey:@"Board"];
        theGame = (Game *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedGame];
        
        [self createSelections];
        

        
//        NSLog(@"GameObject: %@", GameObject);
//        NSLog(@"The Game: %i", theGame.gameBoard.count);
    }
    return self;
}

- (id) initWithUser: (PFObject *) user{
    if ((self = [super init])) {
        opponent = user;
        startedGame = YES;
        
        [self createSelections];
    }
    return self;
}

- (void) createSelections {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCSprite *bg;
    
    if (IS_IPHONE4)
        bg = [CCSprite spriteWithFile:@"bg-iphone4.png"];
    else
        bg = [CCSprite spriteWithFile:@"bg-iphone5.png"];
    
    bg.position = ccp(size.width/2, size.height/2);
    [self addChild:bg];
    
    [[GameLogic sharedGameLogic] showBars];
    
    [[GameLogic sharedGameLogic] createBarItem:@"Online Game"];
    
    NSString *startLabel = @"Start";
    if (startedGame)
        startLabel = @"Request";
    
    CCLabelTTF *start = [CCLabelTTF labelWithString:startLabel fontName:@"Vanilla Whale" fontSize:44];
    start.color = ccc3(0, 0, 0);
    
    CCMenuItem *StartButton = [CCMenuItemImage itemWithNormalImage:@"log.png" selectedImage:@"log_selected.png" target:self selector:@selector(start)];
    start.position = ccp(StartButton.contentSize.width/2, StartButton.contentSize.height/2);
    [StartButton addChild:start];
    StartButton.position = ccp(size.width/2, size.height - 450);
    if (IS_IPHONE4) {
        StartButton.position = ccp(size.width/2, size.height - 380);
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
    [avatarScroll moveToPage:2];
    [[pieces objectAtIndex:2] jump:2];
    [self addChild:avatarScroll z:3];
    
    CCLabelTTF *pickAvatar = [CCLabelTTF labelWithString:@"Select Avatar" fontName:@"Vanilla Whale" fontSize:40];
    pickAvatar.position =  ccp( size.width /2 , size.height - 80);
    pickAvatar.color = ccc3(0, 0, 0);
    [self addChild: pickAvatar];
    
    if (IS_IPHONE4) {
       pickAvatar.position =  ccp( size.width /2 , size.height - 70);
    }
    
    if (startedGame) {
        CCLabelTTF *pickBoard = [CCLabelTTF labelWithString:@"Select Board Size" fontName:@"Vanilla Whale" fontSize:40];
        pickBoard.position =  ccp( size.width /2 , size.height - 300);
        pickBoard.color = ccc3(0, 0, 0);
        [self addChild: pickBoard];
        [self addBoardControl];
        
        if (IS_IPHONE4) {
            pickBoard.position = ccp(size.width/2, size.height - 275);
        }
    } else {
        int edge = [theGame.gameBoard count];
        CCLabelTTF *pickBoard = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Board Size: %i X %i", edge, edge ] fontName:@"Vanilla Whale" fontSize:40];
        pickBoard.position =  ccp( size.width /2 , size.height - 350);
        pickBoard.color = ccc3(0, 0, 0);
        [self addChild: pickBoard];
        
        CCLabelTTF *spriteLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Opponent's Avatar: %@", [[GameLogic sharedGameLogic] convertToFighter:theGame.p1Sprite]] fontName:@"Vanilla Whale" fontSize:40];
        spriteLabel.position =  ccp( size.width /2 , size.height - 300);
        spriteLabel.color = ccc3(0, 0, 0);
        [self addChild: spriteLabel];
        
        if (IS_IPHONE4) {
            pickBoard.position =  ccp( size.width /2 , size.height - 320);
            spriteLabel.position =  ccp( size.width /2 , size.height - 270);
        }
    }
    
    [self setTouchEnabled:YES];
}

- (CCLayer *) createSpriteLayer: (int) number {
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCLayer *layer = [[CCLayer alloc] init];
    Piece *tempItem = [[Piece alloc] init];
    CCNode *node =[tempItem createSprite:number];
    
    CCLabelTTF *name = [CCLabelTTF labelWithString:[[GameLogic sharedGameLogic] convertToFighter:number] fontName:@"Vanilla Whale" fontSize:32];
    [name setColor:ccc3(0, 0, 0)];
    
    if (IS_IPHONE4) {
        node.position = ccp(size.width/2-80, size.height - 235);
        name.position = ccp(size.width/2, size.height - 230);
    } else {
        node.position = ccp(size.width/2-80, size.height - 255);
        name.position = ccp(size.width/2, size.height - 250);
    }
    
    [layer addChild:name];
    [layer addChild:node];
    [pieces addObject:tempItem];
    
    return layer;
}

- (void) addBoardControl {
    UIFont *font = [UIFont fontWithName:@"Marker Felt" size:15];
    NSDictionary *controlSetting = [NSDictionary dictionaryWithObject:font forKey:UITextAttributeFont];
    
    NSArray *boards = [NSArray arrayWithObjects:@"4x4", @"5x5", @"6x6", nil];
    boardSizeControl = [[UISegmentedControl alloc] initWithItems:boards];
    [boardSizeControl setFrame:CGRectMake(10, 330, 300, 44)];
    
    if (IS_IPHONE4) {
        [boardSizeControl setFrame:CGRectMake(10, 300, 300, 44)];
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
    
    [[[CCDirector sharedDirector] view] addSubview:boardSizeControl];

}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    NSLog(@"%f, %f", location.x, location.y);
    touchHeight = location.y;
    
    if (IS_IPHONE4) {
        if (touchHeight > 245 && touchHeight < 380) {
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
        if (touchHeight > 225 && touchHeight < 400) {
            int index = avatarScroll.currentScreen;
            [[pieces objectAtIndex:index] jump:2];
        }
    } else {
        if (touchHeight > 320 && touchHeight < 470) {
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
    NSLog(@"Starting with opponent %@ and settings %c", [opponent objectForKey:@"DisplayName"], startedGame );
    
    if (startedGame) {
        PFObject *newGame = [PFObject objectWithClassName:@"Game"];
        [newGame setObject:[GameLogic sharedGameLogic].playerData forKey:@"Player1"];
        [newGame setObject:opponent forKey:@"Player2"];
        
        Game *currentGame = [[Game alloc] init];
        
        currentGame.p1Sprite = avatarScroll.currentScreen+1;
        NSLog(@"p1Sprite: %i", currentGame.p1Sprite);
        
        currentGame.p1Name = [[GameLogic sharedGameLogic].playerData objectForKey:@"DisplayName"];
        currentGame.p2Name = [opponent objectForKey:@"DisplayName"];
        
        currentGame.p1Score = 0;
        currentGame.p2Score = 0;
        
        currentGame.gameBoard = [[NSMutableArray alloc] init];
        int edgeLength = boardSizeControl.selectedSegmentIndex + 4;
        
        int go = arc4random() % 2;
        BOOL isOne = go == 1 ? YES : NO;
        
        
        currentGame.isPlayer1 = isOne;
        [newGame setObject:[NSNumber numberWithBool:isOne] forKey:@"isPlayer1Turn"];
        
        for (int y = 0; y < edgeLength; y++)
        {
            NSMutableArray *gameRow = [[NSMutableArray alloc] init];
            for (int x = 0; x < edgeLength; x++)
            {
                if (y == 0)
                    [gameRow addObject:[NSNumber numberWithInt:1]];
                else if (y == edgeLength -1)
                    [gameRow addObject:[NSNumber numberWithInt:2]];
                else
                    [gameRow addObject:[NSNumber numberWithInt:0]];
            }
            [currentGame.gameBoard addObject:gameRow];
        }
        
        [newGame setObject:[NSNumber numberWithBool:NO] forKey:@"CanStart"];
        [newGame setObject:[NSNumber numberWithBool:NO] forKey:@"Ended"];
        [newGame setObject:[NSKeyedArchiver archivedDataWithRootObject:currentGame] forKey:@"Board"];
        
        [newGame saveInBackground];
        
        [[GameLogic sharedGameLogic] popViews];
        [[CCDirector sharedDirector] replaceScene:[OnlinePlayerLayer scene]];
    } else {
        if (avatarScroll.currentScreen + 1 == theGame.p1Sprite) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Avatars must be different" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        } else {
            theGame.p2Sprite = avatarScroll.currentScreen+1;
            NSLog(@"p2Sprite: %i", theGame.p2Sprite);
            [GameObject setObject:[NSNumber numberWithBool:YES] forKey:@"CanStart"];
            [GameObject setObject:[NSKeyedArchiver archivedDataWithRootObject:theGame] forKey:@"Board"];
            
            [GameObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [[GameLogic sharedGameLogic] popViews];
                    [[CCDirector sharedDirector] replaceScene:[GameLayer sceneFromGame:GameObject isPlayer1:NO]];
                }
            }];
        }
    }
}
@end
