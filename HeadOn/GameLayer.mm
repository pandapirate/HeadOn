//
//  GameLayer.m
//  HeadOn
//
//  Created by Kevin Huang on 1/26/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import "GameLayer.h"
#import "Position.h"
#import "Piece.h"
#import "qi.h"
#import "SimpleAudioEngine.h"
#import "GameLogic.h"
#import "HelloWorldLayer.h"
#import <Parse/Parse.h>
#import "AutoScrollLabel.h"
#import "Game.h"
#import "GCHelper.h"

@implementation GameLayer
@synthesize allPositions, player1Pieces, player2Pieces;
Move humanMove = Move();
Qi *qi = nil;

+ (CCScene *) sceneWithDifficulty : (int) difficulty  andSprite: (int) sprite1 onBoard: (int) boardSize{
    CCScene *scene = [CCScene node];
    GameLayer *layer = [[GameLayer alloc] initWithDifficulty:difficulty andSprite:sprite1 onBoard: boardSize];
    [scene addChild:layer];
    return scene;
}

+ (CCScene *) sceneFromMemory:(int)gameNumber{
    CCScene *scene = [CCScene node];
    GameLayer *layer = [[GameLayer alloc] initWithMemory:gameNumber];
    [scene addChild:layer];
    return scene;
}

+ (CCScene *) sceneWithPlayer1Sprite: (int) sprite1 andPlayer2Sprite: (int) sprite2 onBoard: (int) boardSize{
    CCScene *scene = [CCScene node];
    GameLayer *layer = [[GameLayer alloc] initWithPlayer1Sprite:sprite1 andPlayer2Sprite:sprite2 onBoard: boardSize];
    [scene addChild:layer];
    return scene;
}

+ (CCScene *) sceneFromGame: (PFObject *) gameObj isPlayer1: (BOOL) p1 {
    CCScene *scene = [CCScene node];
    GameLayer *layer = [[GameLayer alloc] initWithGame:gameObj isPlayer1: p1];
    [scene addChild:layer];
    return scene;
}

// Resume Online
- (id) initWithGame:(PFObject *) gameObj isPlayer1: (BOOL) p1 {
    if (self = [super initWithColor:ccc4(255, 255, 255, 255)]) {
        NSData *encodedGame = [gameObj objectForKey:@"Board"];
        currentGame = (Game *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedGame];
        GameObject = gameObj;
        onlinePlayer1 = p1;
        onlineGame = YES;
        
        if (currentGame) {
            [self loadFromGame];
            
            [self watchMoveAndSaveBoard: isPlayer1];
        }
    }
    return self;
}

// Resume Local
- (id) initWithMemory:(int) gameNumber {
    if (self = [super initWithColor:ccc4(255, 255, 255, 255)]) {
        currentGameName = [NSString stringWithFormat:@"Game%i", gameNumber];
        
        NSData *encodedGame = [[NSUserDefaults standardUserDefaults] objectForKey:currentGameName];
        currentGame = (Game *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedGame];
        onlineGame = NO;
        if (currentGame) {
            [self loadFromGame];
        }
        
        if (qi)
            canMakeMistake = YES;
    }
    return self;
}

// Two Players
- (id) initWithPlayer1Sprite: (int) sprite1 andPlayer2Sprite: (int) sprite2 onBoard: (int) boardSize{
    if (self = [super initWithColor:ccc4(255, 255, 255, 255)]) {
        player1Sprite = sprite1;
        player2Sprite = sprite2;
        
        p1Name = @"Player 1";
        p2Name = @"Player 2";
        
        qi = nil;
        
        edgeLength = boardSize;
        onlineGame = NO;
        [self setUpLabels];
        [self setUpNewBoard];
        [self setUpNewGame: -1];
    }
    return self;
}

// Single Player
- (id) initWithDifficulty: (int) difficulty  andSprite: (int) sprite1 onBoard: (int) boardSize{
    if (self = [super initWithColor:ccc4(255, 255, 255, 255)]) {
        edgeLength = boardSize;
        onlineGame = NO;
        qi = new Qi(edgeLength, difficulty);
        player1Sprite = sprite1;
        canMakeMistake = YES;
        
        while (true) {
            int p2 = arc4random() % 10 + 1;
            if (p2 != sprite1) {
                player2Sprite = p2;
                break;
            }
        }
        
        p1Name = @"Anonymous";
        if ([[[GameLogic sharedGameLogic].playerData objectForKey:@"DisplayName"] length] > 0)
            p1Name = [[GameLogic sharedGameLogic].playerData objectForKey:@"DisplayName"];
        
        switch (difficulty) {
            case 2:
                p2Name = @"Rookie Computer";
                break;
            case 3:
                p2Name = @"Normal Computer";
                break;
            case 4:
                p2Name = @"Veteran Computer";
                break;
            case 5:
                p2Name = @"Master Computer";
                break;
            default:
                break;
        }
        
        [self setUpLabels];
        [self setUpNewBoard];
        [self setUpNewGame: difficulty];
    }
    
    return self;
}

- (void) loadFromGame {
    player1Sprite = currentGame.p1Sprite;
    player2Sprite = currentGame.p2Sprite;
//    NSLog(@"Sprites: %i, %i", player1Sprite, player2Sprite);
    p1Name = currentGame.p1Name;
    p2Name = currentGame.p2Name;
    
    edgeLength = currentGame.gameBoard.count;
    
    if (currentGame.difficulty) {
        qi = new Qi(edgeLength, currentGame.difficulty);
    } else {
        qi = nil;
    }
    
    [self setUpLabels];
    [self setUpExistingBoard:currentGame.gameBoard];
    
    isPlayer1 = currentGame.isPlayer1;
    
    if (!isPlayer1) {
        currentPlayerMarker.position = ccp(blobHeight2, 110);
        if (qi)
            [self computerMove];
    }
    
    if (isPlayer1)
        [p1Sprite jump:100];
    else
        [p2Sprite jump:100];
    
    p1Score.text = [NSString stringWithFormat:@"%i", currentGame.p1Score];
    p2Score.text = [NSString stringWithFormat:@"%i", currentGame.p2Score];
}

- (void) setUpNewBoard {
    
    for (int i = 0; i < edgeLength; i++) {
        NSMutableArray *row = [[NSMutableArray alloc] init];
        for (int j = 0; j < edgeLength; j++) {
            Position *temp = [[Position alloc] init];
            
            temp.x = startX + j * deltaX;
            temp.y = startY + i * deltaY;
            temp.boardX = j;
            temp.boardY = i;
            
            if (i == 0) {
                [self addPieceForPlayer1:YES atLocation:temp];
            }
            else if (i == edgeLength-1) {
                [self addPieceForPlayer1:NO atLocation:temp];
            }
            else
                temp.piece = 0;
            
            [row addObject:temp];
        }
        [allPositions addObject:row];
    }
    
    int rand = arc4random() % 2;

    if (rand == 1) {
        currentPlayerMarker.position = ccp(blobHeight2, 110);
        isPlayer1 = NO;
        [p2Sprite jump:100];
        if (qi) {
            [self computerMove];
        }
    } else
        [p1Sprite jump:100];    
}

- (void) setUpExistingBoard: (NSMutableArray *) positions {
    for (int i = 0; i < edgeLength; i++) {
        NSMutableArray *row = [[NSMutableArray alloc] init];
        NSMutableArray *gameRow = [positions objectAtIndex:i];
        
        for (int j = 0; j < edgeLength; j++) {
            int gamePosition = [[gameRow objectAtIndex:j] intValue];
            Position *temp = [[Position alloc] init];
            
            temp.x = startX + j * deltaX;
            temp.y = startY + i * deltaY;
            temp.boardX = j;
            temp.boardY = i;
            
            if (gamePosition == 1) {
                [self addPieceForPlayer1:YES atLocation:temp];
            }
            else if (gamePosition == 2) {
                [self addPieceForPlayer1:NO atLocation:temp];
            }
            else
                temp.piece = 0;
            
            [row addObject:temp];
        }
        [allPositions addObject:row];
    }
}

- (void) setUpLabels {

    startX = 24;
    startY = 170;
    deltaX = 90;
    deltaY = 92;
    
    switch (edgeLength) {
        case 5: {
            startX = 20;
            startY = 170;
            deltaX = 70;
            deltaY = 71;
            break;
        }
        case 6: {
            startX = 18;
            startY = 170;
            deltaX = 57;
            deltaY = 57;
            break;
        }
        default:
            break;
    }
    
    allPositions = [[NSMutableArray alloc] init];
    player1Pieces = [[NSMutableArray alloc] init];
    player2Pieces = [[NSMutableArray alloc] init];
    
    [[GameLogic sharedGameLogic] showBars];
    if (IS_IPHONE4) {
        startY += 10;
        
        [GameLogic sharedGameLogic].navBar.hidden = YES;
    } else
        [[GameLogic sharedGameLogic] createBarItem:@"Head On"];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    backgroundColor = arc4random() % 4 + 1;
    CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%i-%i.jpg", backgroundColor, edgeLength]];
    bg.position = ccp(winSize.width/2, winSize.height/2 + 3);
    [self addChild:bg];
    
    if (IS_IPHONE4) {
        bg.position = ccp(winSize.width/2, winSize.height/2 + 50);
        startY -= 7;
    }
    
    self.touchEnabled = YES;
    
    currentPieceGlow = [CCSprite spriteWithFile:@"blur.png"];
    currentPieceGlow.visible = NO;
    currentPieceGlow.scaleX = 1.5;
    currentPieceGlow.scaleY = 4;
    [self addChild:currentPieceGlow z:1];
    
    currentPlayerMarker = [CCSprite spriteWithFile:@"blur.png"];
    
    blobHeight1 = 100;
    blobHeight2 = 220;
    
    currentPlayerMarker.position = ccp(blobHeight1, 110);
    
    currentPlayerMarker.scaleY = 3;
    currentPlayerMarker.scaleX = 3;
    [self addChild:currentPlayerMarker z:4];
    
    CCSprite *board = [CCSprite spriteWithFile:@"woodbar.png"];
    board.position = ccp(winSize.width/2, 100);
    board.scaleY = 1.8;
    [self addChild:board];
    
    UIFont *labelFont = [UIFont fontWithName:@"BoisterBlack" size: 22];
    
    p1Score = [[UILabel alloc] init];
    p1Score.text = @"0";
    p1Score.textColor = [UIColor colorWithRed:50./255 green:20./255 blue:6./255 alpha:255];
    p1Score.frame = CGRectMake(53, 470, 100, 28);
    p1Score.font = labelFont;
    p1Score.backgroundColor = [UIColor clearColor];
    [[[CCDirector sharedDirector] view] addSubview:p1Score];
    
    AutoScrollLabel *p1NameLabel = [[AutoScrollLabel alloc] init];
    p1NameLabel.frame = CGRectMake(53, 443, 100, 28);
    p1NameLabel.textColor = [UIColor colorWithRed:50./255 green:20./255 blue:6./255 alpha:255];
    p1NameLabel.font = labelFont;
    p1NameLabel.text = p1Name;
    [[[CCDirector sharedDirector] view] addSubview:p1NameLabel];
    
    p2Score = [[UILabel alloc] init];
    p2Score.text = @"0";
    p2Score.font = labelFont;
    p2Score.backgroundColor = [UIColor clearColor];
    p2Score.textColor = [UIColor colorWithRed:50./255 green:20./255 blue:6./255 alpha:255];
    p2Score.frame = CGRectMake(167, 470, 100, 28);
    [p2Score setTextAlignment:NSTextAlignmentRight];
    [[[CCDirector sharedDirector] view] addSubview:p2Score];
    
    AutoScrollLabel *p2NameLabel = [[AutoScrollLabel alloc] init];
    p2NameLabel.frame = CGRectMake(167, 443, 100, 28);
    p2NameLabel.textColor = [UIColor colorWithRed:50./255 green:20./255 blue:6./255 alpha:255];
    p2NameLabel.font = labelFont;
    p2NameLabel.text = p2Name;
    [[[CCDirector sharedDirector] view] addSubview:p2NameLabel];
    
    if (IS_IPHONE4) {
        [p1Score setFrame:CGRectMake(53, 380, 100, 28)];
        [p2Score setFrame:CGRectMake(167, 380, 100, 28)];
        [p1NameLabel setFrame:CGRectMake(53, 353, 100, 28)];
        [p2NameLabel setFrame:CGRectMake(167, 353, 100, 28)];
    }
    
    p1Sprite = [[Piece alloc] init];
    p2Sprite = [[Piece alloc] init];
    
    CCNode *p1Node = [p1Sprite createSprite:player1Sprite];
    CCNode *p2Node = [p2Sprite createSprite:player2Sprite];
    p1Node.scale = 0.45;
    p2Node.scale = 0.45;
    
    p1AvatarSpot = ccp(-10, 60);
    p2AvatarSpot = ccp(260, 60);
    
    p1Node.position = p1AvatarSpot;
    p2Node.position = p2AvatarSpot;
    [self addChild:p1Node z: 5];
    [self addChild:p2Node z: 5];
    
    isMoving = NO;
    isPlayer1 = YES;
    currentPiece = nil;
}

- (void) setUpNewGame: (int) difficulty {
    NSLog(@"Creating New Game");
    
    int counter = 1;
    while (true){
        currentGameName = [NSString stringWithFormat:@"Game%i", counter];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:currentGameName])
            counter++;
        else
            break;
        
        //If all spots filled, don't create new game;
        if (counter > 10) {
            counter = NULL;
            currentGameName = NULL;
            currentGame = NULL;
            break;
        }
    }
    
    if (counter == NULL) {
        NSLog(@"All Slots Full");
        return;
    }
    
    NSLog(@"Game Name: %@", currentGameName);
    
    currentGame = [[Game alloc] init];
    
    currentGame.gameNumber = counter;
    
    currentGame.p1Sprite = player1Sprite;
    currentGame.p2Sprite = player2Sprite;
    
    currentGame.p1Name = p1Name;
    currentGame.p2Name = p2Name;
    
    currentGame.p1Score = 0;
    currentGame.p2Score = 0;
    
    if (difficulty > 0) {
        currentGame.difficulty = difficulty;
    }
    
    currentGame.gameBoard = [[NSMutableArray alloc] init];
    
    for (int y = 0; y < edgeLength; y++)
    {
        NSMutableArray *row = [allPositions objectAtIndex:y];
        NSMutableArray *gameRow = [[NSMutableArray alloc] init];
        for (int x = 0; x < edgeLength; x++)
        {
            Position *p = [row objectAtIndex:x];
            [gameRow addObject:[NSNumber numberWithInt:p.piece]];
        }
        [currentGame.gameBoard addObject:gameRow];
    }
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isMoving)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    //    NSLog(@"%f, %f", location.x, location.y);
    
    CGRect touchLocation = CGRectMake(location.x-15, location.y-15, 30, 30);
    
    for (Piece *s in (isPlayer1 ? player1Pieces : player2Pieces)) {
        CGRect pieceBox = CGRectMake(s.p.x - 15, s.p.y - 15, 30, 30);
        
        if (CGRectIntersectsRect(pieceBox, touchLocation)) {
            currentPiece = s;
//            isMoving = YES;
//            [s jump:1];
            currentPieceGlow.position = ccp(s.p.x, s.p.y);
            currentPieceGlow.visible = YES;
            
//            [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0],[CCCallBlock actionWithBlock:^{
//                isMoving = NO;
//            }], nil]];
            
            //            NSLog(@"Selected a Piece at: %i, %i", s.p.boardX, s.p.boardY);
            
            return;
        }
    }
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (isMoving)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
//    NSLog(@"%f, %f", location.x, location.y);
    
    CGRect touchLocation = CGRectMake(location.x-15, location.y-15, 30, 30);
    
//    for (Piece *s in (isPlayer1 ? player1Pieces : player2Pieces)) {
//        CGRect pieceBox = CGRectMake(s.p.x - 15, s.p.y - 15, 30, 30);
//        
//        if (CGRectIntersectsRect(pieceBox, touchLocation)) {
//            currentPiece = s;
//            isMoving = YES;
//            [s jump:1];
//            currentPieceGlow.position = ccp(s.p.x, s.p.y);
//            currentPieceGlow.visible = YES;
//            
//            [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0],[CCCallBlock actionWithBlock:^{
//                isMoving = NO;
//            }], nil]];
//            
////            NSLog(@"Selected a Piece at: %i, %i", s.p.boardX, s.p.boardY);
//            
//            return;
//        }
//    }
    
    if (currentPiece) {
        Position *tempP = nil;
        BOOL found = NO;
        //find position
        for (NSMutableArray *row in allPositions) {
            for (Position *pp in row) {
                CGRect box = CGRectMake(pp.x-15, pp.y-15, 30, 30);
                if (CGRectIntersectsRect(box, touchLocation)) {
                    tempP = pp;
                    found = YES;
                    break;
                }
            }
            if (found)
                break;
        }
        char direction = 'a';
        
        //found position
        if (tempP) {
            Position *destination = nil;
            
            //left
            if (tempP.boardX == currentPiece.p.boardX - 1 && tempP.boardY == currentPiece.p.boardY) {
                destination = [[allPositions objectAtIndex:currentPiece.p.boardY] objectAtIndex:(currentPiece.p.boardX-1)];
                direction = 'l';
            }
            //right
            if (tempP.boardX == currentPiece.p.boardX + 1 && tempP.boardY == currentPiece.p.boardY) {
                destination = [[allPositions objectAtIndex:currentPiece.p.boardY] objectAtIndex:(currentPiece.p.boardX+1)];
                direction = 'r';
            }
            
            //up
            if (tempP.boardX == currentPiece.p.boardX && tempP.boardY == currentPiece.p.boardY + 1) {
                destination = [[allPositions objectAtIndex:currentPiece.p.boardY+1] objectAtIndex:(currentPiece.p.boardX)];
                direction = 'u';
            }
            
            //down
            if (tempP.boardX == currentPiece.p.boardX && tempP.boardY == currentPiece.p.boardY - 1) {
                destination = [[allPositions objectAtIndex:currentPiece.p.boardY-1] objectAtIndex:(currentPiece.p.boardX)];
                direction = 'd';
            }
            
            if (destination.piece != 0 || direction == 'a')
                return;
            
//            NSLog(@"Direction : %c from %i, %i to %i, %i", direction, currentPiece.p.boardX, currentPiece.p.boardY, destination.boardX, destination.boardY);
            
            
            [self moveCurrentPieceToLocation:destination forComputer:NO];
        }
    }
 }       

- (void) checkCapture: (Position *) destination {
    NSMutableArray *capturedPieces = [[GameLogic sharedGameLogic] checkCaptureOnBoard:allPositions forPlayer:isPlayer1 atPosition:destination];
    
//    NSLog(@"Number: %i", capturedPieces.count);
    NSMutableArray *deletedPieces = [[NSMutableArray alloc] init];
    
    for (Position *pos in capturedPieces) {
//        NSLog(@"Capture Location: %i, %i", pos.boardX, pos.boardY);
        
        for (Piece *piece in isPlayer1 ? player2Pieces : player1Pieces) {
            if (piece.p.boardX == pos.boardX && piece.p.boardY == pos.boardY) {
                piece.p.piece = 0;
                [deletedPieces addObject:piece];
            }
        }
    }
    
    if ([deletedPieces count] > 0){
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSound"])
            [[SimpleAudioEngine sharedEngine] playEffect:@"sword.aif"];
    }
    
    if (!watchingGame) {
        int score = isPlayer1 ? [p1Score.text intValue] : [p2Score.text intValue];
        
        if ([deletedPieces count] == 1) {
            score += 1000;
        } else
            score += [deletedPieces count] * 1500;
        
        if (isPlayer1)
            [p1Score setText:[NSString stringWithFormat:@"%i", score]];
        else
            [p2Score setText:[NSString stringWithFormat:@"%i", score]];
    }
    
    for (Piece *piece in deletedPieces) {
        [piece getCaptured];
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.8],
                         [CCCallBlock actionWithBlock:^{
            [self removeChild:piece.group cleanup:YES];
        }], nil]];
        
        if (isPlayer1) {
            [player2Pieces removeObject:piece];
//            NSLog(@"Removing from 2");
        } else {
            [player1Pieces removeObject:piece];
//            NSLog(@"Removing from 1");
        }
    }
    
//    NSLog(@"Number left: %i, %i", player1Pieces.count, player2Pieces.count);
}

- (void) computerMove {
    if (isMoving)
        return;
    
    int random = arc4random() % 100;
    BOOL randomMove = NO;
    switch (qi->depth) {
        case 2:
            randomMove = random < 60 ? YES : NO;
            break;
        case 3:
            randomMove = random < 40 ? YES : NO;
            break;
        case 4:
            randomMove = random < 20 ? YES : NO;
            break;
        case 5:
            randomMove = random < 10 ? YES : NO;
            break;
        default:
            break;
    }
    
    Move *compMove;
    
    if (canMakeMistake && randomMove) {
        compMove = new Move();
        
        NSMutableArray *moves;
        int piece;
        Position *p;
        while (true) {
            piece = arc4random() % player2Pieces.count;
            moves = [[NSMutableArray alloc] init];
            Piece *t = [player2Pieces objectAtIndex:piece];
            p = t.p;
            Position *temp;
            // top = 0
            if (p.boardY <= edgeLength - 2) {
                temp = [[allPositions objectAtIndex:p.boardY + 1] objectAtIndex:p.boardX];
                if (temp.piece == 0)
                    [moves addObject:@"0"];
            }
            
            // right = 1
            if (p.boardX <= edgeLength - 2) {
                temp = [[allPositions objectAtIndex:p.boardY] objectAtIndex:p.boardX + 1];
                if (temp.piece == 0)
                    [moves addObject:@"1"];
            }
            
            // bot = 2
            if (p.boardY >= 1) {
                temp = [[allPositions objectAtIndex:p.boardY - 1] objectAtIndex:p.boardX];
                if (temp.piece == 0)
                    [moves addObject:@"2"];
            }
            
            // left = 3
            if (p.boardX >= 1) {
                temp = [[allPositions objectAtIndex:p.boardY] objectAtIndex:p.boardX - 1];
                if (temp.piece == 0)
                    [moves addObject:@"3"];
            }
            
            if (moves.count > 0)
                break;
        }
        NSLog(@"Random Moves for piece: %i - %@", piece, moves);
        piece = arc4random() % moves.count;
        NSLog(@"Random: %i, object: %@", piece, [moves objectAtIndex:piece]);
        Position *finalPos;
        switch ([[moves objectAtIndex:piece] intValue]) {
            case 0:
                finalPos = [[allPositions objectAtIndex:p.boardY + 1] objectAtIndex:p.boardX];
                break;
            case 1:
                finalPos = [[allPositions objectAtIndex:p.boardY] objectAtIndex:p.boardX + 1];
                break;
            case 2:
                finalPos = [[allPositions objectAtIndex:p.boardY - 1] objectAtIndex:p.boardX];
                break;
            case 3:
                finalPos = [[allPositions objectAtIndex:p.boardY] objectAtIndex:p.boardX - 1];
                break;
            default:
                break;
        }
        
        compMove->xf = p.boardX;
        compMove->yf = p.boardY;
        compMove->xt = finalPos.boardX;
        compMove->yt = finalPos.boardY;
        
    } else {
        
        for (int y = 0; y < edgeLength; y++)
        {
            NSMutableArray *row = [allPositions objectAtIndex:y];
            for (int x = 0; x < edgeLength; x++)
            {
                Position *pp = [row objectAtIndex:x];
                qi->tiles[x][y] = pp.piece;
            }
        }
        
        compMove = qi->computerMove();
    }
    
    //Move *compMove = qi->computerMove();
    NSLog(@"COMPUTER: : move piece from %d, %d to %d, %d\n", compMove->xf, compMove->yf, compMove->xt, compMove->yt);
    
    Position *p = [[allPositions objectAtIndex:compMove->yf] objectAtIndex:compMove->xf];
    [self findCurrentPiece:p];
    
    Position *pt = [[allPositions objectAtIndex:compMove->yt] objectAtIndex:compMove->xt];
    
    [self moveCurrentPieceToLocation:pt forComputer:YES];
}

- (void) watchMoveAndSaveBoard: (BOOL) originalP1 {
    NSLog(@"Watching Last Turn from player %@", isPlayer1 ? @"1" : @"2");
//    NSLog(@"Moving piece from %f, %f to %f, %f\n", currentGame.from.x, currentGame.from.y, currentGame.to.x,currentGame.to.y);
    if (currentGame.from.x != -1 && currentGame.to.x != -1) {
        watchingGame = YES;
        isMoving = NO;
        
        isPlayer1 = !isPlayer1;
        
        Position *from = [[allPositions objectAtIndex:currentGame.from.y] objectAtIndex:currentGame.from.x];
        Position *to = [[allPositions objectAtIndex:currentGame.to.y] objectAtIndex:currentGame.to.x];
        
//        NSLog(@"Trying to move %i, %i to %i, %i\n", from.boardX, from.boardY, to.boardX, to.boardY);
        [self findCurrentPiece:from];
        [self moveCurrentPieceToLocation:to forComputer:NO];
        
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.1],[CCCallBlock actionWithBlock:^{
            for (int y = 0; y < edgeLength; y++)
            {
                NSMutableArray *row = [allPositions objectAtIndex:y];
                NSMutableArray *gameRow = [currentGame.gameBoard objectAtIndex:y];
                for (int x = 0; x < edgeLength; x++)
                {
                    Position *p = [row objectAtIndex:x];
                    [gameRow setObject:[NSNumber numberWithInt:p.piece] atIndexedSubscript:x];
                }
            }
            
            watchingGame = NO;
            isMoving = NO;
            
            isPlayer1 = originalP1;
            
            if (onlinePlayer1 && isPlayer1) {
                isMoving = NO;
            } else if (!onlinePlayer1 && !isPlayer1) {
                isMoving = NO;
            } else
                isMoving = YES;
            
        }], nil]];
    }
}

- (void) findCurrentPiece: (Position *) p {
    CGRect locBox = CGRectMake(p.x-15, p.y-15, 30, 30);
    
    for (Piece *c in (isPlayer1 ? player1Pieces : player2Pieces)) {
        CGRect pieceBox = CGRectMake(c.p.x - 15, c.p.y - 15, 30, 30);
        
        if (CGRectIntersectsRect(locBox, pieceBox)) {
            currentPiece = c;
            break;
        }
    }
    
//    NSLog(@"Found Piece: %i, %i", currentPiece.p.boardX, currentPiece.p.boardY);
}

- (void) moveCurrentPieceToLocation: (Position *) to forComputer: (BOOL) computer{
    isMoving = YES;
    NSLog(@"Moving piece from %i, %i to %i, %i\n", currentPiece.p.x, currentPiece.p.y, to.x, to.y);

    
    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:1.0 position:ccp(to.x-40, to.y-40)];
    CCCallBlockN *actionDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        currentPiece.p.piece = 0;
        Position *tempPos = currentPiece.p;
        to.piece = isPlayer1 ? 1 : 2;
        currentPiece.p = to;
        
        if (isPlayer1) {
            currentPlayerMarker.position = ccp(blobHeight2, 110);
            [p1Sprite reset:p1AvatarSpot];
            [p2Sprite jump:100];
        } else {
            currentPlayerMarker.position = ccp(blobHeight1, 110);
            [p2Sprite reset:p2AvatarSpot];
            [p1Sprite jump:100];
        }

        currentPieceGlow.visible = NO;
        
        [self checkCapture:to];
        isPlayer1 = !isPlayer1;

        if (onlineGame)
            isMoving = YES;
        else
            isMoving = NO;
        
        currentPiece = nil;
        
        if (!watchingGame) {
            if (currentGame)
                [self recordTurnFrom:tempPos goingTo:to];
        }
        
        [self checkWon];
        
        if (!computer and qi)
            [self computerMove];
    }];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSound"]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"bop.mp3"];
    }
    
    char direction = 'a';
    if (to.x < currentPiece.p.x)
        direction = 'l';
    else if (to.x > currentPiece.p.x)
        direction = 'r';
    else if (to.y > currentPiece.p.y)
        direction = 'u';
    else
        direction = 'd';
    
    switch (direction) {
        case 'l':
            [currentPiece walkLeft:2];
            break;
        case 'r':
            [currentPiece walkRight:2];
            break;
        case 'u':
            [currentPiece walkUp:1];
            break;
        case 'd':
            [currentPiece walkDown:1];
            break;
        default:
            break;
    }
    if (!computer)
        [currentPieceGlow runAction:[CCMoveTo actionWithDuration:1.0 position:ccp(to.x, to.y)]];
    [currentPiece.group runAction:[CCSequence actions:actionMove, actionDone, nil]];
}

- (void) recordTurnFrom: (Position *) from goingTo: (Position *) to {
    currentGame.p1Score = [p1Score.text intValue];
    currentGame.p2Score = [p2Score.text intValue];
    
    currentGame.isPlayer1 = isPlayer1;
    
    if (!onlineGame) {
        for (int y = 0; y < edgeLength; y++)
        {
            NSMutableArray *row = [allPositions objectAtIndex:y];
            NSMutableArray *gameRow = [currentGame.gameBoard objectAtIndex:y];
            for (int x = 0; x < edgeLength; x++)
            {
                Position *p = [row objectAtIndex:x];
                [gameRow setObject:[NSNumber numberWithInt:p.piece] atIndexedSubscript:x];
            }
        }
    } else {
        currentGame.from = ccp(from.boardX, from.boardY);
        currentGame.to = ccp(to.boardX, to.boardY);
    }
    
    if (onlineGame) {
//        NSLog(@"%f, %f", currentGame.to.x, currentGame.to.y);
        NSLog(@"Recording Turn Online");
        [GameObject setObject:[NSKeyedArchiver archivedDataWithRootObject:currentGame] forKey:@"Board"];
        [GameObject setObject:[NSNumber numberWithBool:isPlayer1] forKey:@"isPlayer1Turn"];
        [GameObject saveInBackground];
        
        [self runAction:
         [CCSequence actions:
          [CCDelayTime actionWithDuration:1],
          [CCCallBlockN actionWithBlock:^(CCNode *node) {
             [[GameLogic sharedGameLogic] popViews];
             [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
         }], nil]];
    } else {
        NSLog(@"Recording Turn Local");
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:currentGame] forKey:currentGameName];
    }
}

- (void) checkWon {
    if (player1Pieces.count <= 1 || player2Pieces.count <= 1) {
        int p1 = [p1Score.text intValue];
        int p2 = [p2Score.text intValue];
        
        if (p1 > p2){
            [self playAnimation:YES];
            isMoving = YES;
        } else {
            [self playAnimation:NO];
            isMoving = YES;
        }
    }
}

- (void) playAnimation: (BOOL) won {
    
    NSString * message;
    
    if (qi) {
        if (won) {
            message = @"Congratulations \n You Win!!";
        } else {
            message = @"Better Luck Next Time..";
        }
    
    } else {
        if (won) {
            message = [NSString stringWithFormat:@"Congratulations \n %@ Wins!!", p1Name];
        } else {
            message = [NSString stringWithFormat:@"Congratulations \n %@ Wins!!", p2Name];
        }
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CCLabelTTF *winLabel = [CCLabelTTF labelWithString:message fontName:@"Vanilla Whale" fontSize:42];
    winLabel.color = ccc3(50,25,10);
    winLabel.position = ccp(winSize.width/2, winSize.height/2 - 45);
    [self addChild:winLabel z:5];
    
    Piece *p = [[Piece alloc] init];
    CCNode *pp = [p createSprite: (won ? player1Sprite : player2Sprite)];
    pp.position = ccp(winSize.width/2 - 80, winSize.height/2 + 5);
    [self addChild:pp z: 10];
    [p jump:5];
    
    [self recordStatistics:won];
    
    int exp = [self calculateExperienceForWinner:won];
    NSString *expMsg = [NSString stringWithFormat:@"Experience: +%i", exp];
    CCLabelTTF *expLabel = [CCLabelTTF labelWithString:expMsg fontName:@"Vanilla Whale" fontSize:42];
    expLabel.color = ccc3(50,25,10);
    expLabel.position = ccp(winSize.width/2, winSize.height/2 - 100);
    
    if (backgroundColor == 2) {
        winLabel.color = ccc3(250,250,10);
        expLabel.color = ccc3(250,250,10);
    }
    
    if (qi or onlineGame)
        [self addChild:expLabel z:5];
    
    if (!onlineGame) {
        if (currentGameName)
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:currentGameName];
    }
    
    [self runAction:
     [CCSequence actions:
      [CCDelayTime actionWithDuration:3],
      [CCCallBlockN actionWithBlock:^(CCNode *node) {
         [[GameLogic sharedGameLogic] popViews];
         [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
     }],
      nil]];
}

- (void) addPieceForPlayer1: (BOOL) player1 atLocation: (Position*) loc {
    
    if (player1) {
        loc.piece = 1;
        Piece *piece = [[Piece alloc] init];
        CCNode *node = [piece createSprite:player1Sprite];
        node.scale = 0.5;
        node.position = ccp(loc.x-40, loc.y-40);
        piece.p = loc;
        
        [player1Pieces addObject:piece];
        [self addChild:node z:5];
    }
    else {
        loc.piece = 2;
        Piece *piece = [[Piece alloc] init];
        CCNode *node = [piece createSprite:player2Sprite];
        node.scale = 0.5;
        node.position = ccp(loc.x-40, loc.y-40);
        piece.p = loc;
        
        [player2Pieces addObject:piece];
        [self addChild:node z:5];
    }
}

- (void) recordStatistics: (BOOL) won{
//    NSLog(@"Recording Statistics");
    
    if (qi) {
        [[GCHelper sharedInstance] addGameOnBoard:edgeLength againstComputer:qi->depth isOnlineGame:onlineGame p1Won:won];
        int exp = [self calculateExperienceForWinner:won];
        [[GCHelper sharedInstance] submitHighScore:exp forCategory:@"HeadOn.HighScore"];
        
        exp += [[[GameLogic sharedGameLogic].playerData objectForKey:@"Experience"] intValue];
        [[GameLogic sharedGameLogic].playerData setObject:[NSNumber numberWithInt:exp] forKey:@"Experience"];
        [[GameLogic sharedGameLogic].playerData saveInBackground];
    } else
        [[GCHelper sharedInstance] addGameOnBoard:edgeLength againstComputer:-1 isOnlineGame:onlineGame p1Won:won];
    
    if (onlineGame) {
        PFObject *p1 = [GameObject objectForKey:@"Player1"];
        PFObject *p2 = [GameObject objectForKey:@"Player2"];
        
        int p1Total = [[p1 objectForKey:@"OnlineTotal"] intValue];
        int p2Total = [[p2 objectForKey:@"OnlineTotal"] intValue];
        
        int p1Win = [[p1 objectForKey:@"OnlineWins"] intValue];
        int p2Win = [[p2 objectForKey:@"OnlineWins"] intValue];
        
        int p1Exp = [[p1 objectForKey:@"Experience"] intValue];
        int p2Exp = [[p2 objectForKey:@"Experience"] intValue];
        
        int winexp = [self calculateExperienceForWinner:YES];
        int lossexp = [self calculateExperienceForWinner:NO];
        
        if (won) {
            [p1 setObject:[NSNumber numberWithInt:p1Exp + winexp] forKey:@"Experience"];
            [p2 setObject:[NSNumber numberWithInt:p2Exp + lossexp] forKey:@"Experience"];
            p1Win++;
        } else {
            [p1 setObject:[NSNumber numberWithInt:p1Exp + lossexp] forKey:@"Experience"];
            [p2 setObject:[NSNumber numberWithInt:p2Exp + winexp] forKey:@"Experience"];
            p2Win++;
        }
        
        p1Total++;
        p2Total++;
        
        [p1 setObject:[NSNumber numberWithInt:p1Total] forKey:@"OnlineTotal"];
        [p2 setObject:[NSNumber numberWithInt:p2Total] forKey:@"OnlineTotal"];
        
        [p1 setObject:[NSNumber numberWithInt:p1Win] forKey:@"OnlineWins"];
        [p2 setObject:[NSNumber numberWithInt:p2Win] forKey:@"OnlineWins"];
        
        [GameObject setObject:[NSNumber numberWithBool:YES] forKey:@"Ended"];
        [GameObject saveInBackground];
        
        [p1 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error)
                NSLog(@"Error p1");
        }];
        
        [p2 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error)
                NSLog(@"Error p2");
        }];
        

        
        if (onlinePlayer1 && p1Win) 
            [[GCHelper sharedInstance] submitHighScore:([p1Score.text intValue] + winexp) forCategory:@"HeadOn.HighScore"];
        else if (onlinePlayer1 && !p1Win) 
            [[GCHelper sharedInstance] submitHighScore:([p1Score.text intValue] + lossexp) forCategory:@"HeadOn.HighScore"];
        else if (!onlinePlayer1 && p1Win)
            [[GCHelper sharedInstance] submitHighScore:([p2Score.text intValue] + lossexp) forCategory:@"HeadOn.HighScore"];
        else
            [[GCHelper sharedInstance] submitHighScore:([p2Score.text intValue] + winexp) forCategory:@"HeadOn.HighScore"];
    }
}


- (int) calculateExperienceForWinner: (BOOL) p1Win {
    int exp = 0;
    if (!onlineGame) {
        if (p1Win) {
            exp += edgeLength * 300;
            if (qi)
                exp += qi->depth * 500;
        } else {
            exp += edgeLength * 150;
            if (qi)
                exp += qi->depth * 250;
        }
        
        exp += [p1Score.text intValue];
    } else {
        PFObject *p1 = [GameObject objectForKey:@"Player1"];
        PFObject *p2 = [GameObject objectForKey:@"Player2"];
        
        int p1Exp = [[p1 objectForKey:@"Experience"] intValue] + [p1Score.text intValue];
        int p2Exp = [[p2 objectForKey:@"Experience"] intValue] + [p2Score.text intValue];

        int p1Level = [[GameLogic sharedGameLogic] calculateLevel:p1Exp];
        int p2Level = [[GameLogic sharedGameLogic] calculateLevel:p2Exp];
        int diff = ABS(p2Level - p1Level);
        
        int coef = 10;
        
        if (onlinePlayer1) {
            if (p1Level > p2Level) {
                coef -= diff * 1;
            } else {
                coef += diff * 2;
            }
        } else {
            if (p1Level > p2Level) {
                coef += diff * 2;
            } else {
                coef -= diff * 1;
            }
        }
        
        if (coef < 1)
            coef = 1;
        
        if (coef > 20)
            coef = 20;

        if (p1Win) {
            exp += edgeLength * 200;
            exp += coef * 300;
        } else {
            exp += edgeLength * 100;
            exp += coef * 150;
        }
    }
    return exp;
}

@end
