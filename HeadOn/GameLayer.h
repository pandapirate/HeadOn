//
//  GameLayer.h
//  HeadOn
//
//  Created by Kevin Huang on 1/26/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Piece.h"
#import "Game.h"
#import "Puzzle.h"

@interface GameLayer : CCLayerColor {
    BOOL isMoving;
    Piece *currentPiece;
    BOOL isPlayer1, onlineGame, onlinePlayer1, overrideMove, watchingGame, canMakeMistake, puzzleMode;
    int turns;
    int backgroundColor;
    int edgeLength, blobHeight1, blobHeight2;
    int startX, startY, deltaX, deltaY;
    UILabel *p1Score, *p2Score;
    CCSprite *currentPlayerMarker, *currentPieceGlow;
    NSString *p1Name, *p2Name;
    int player1Sprite, player2Sprite;
    NSString *currentGameName;
    Game *currentGame;
    PFObject *GameObject;
    Piece *p1Sprite, *p2Sprite;
    CGPoint p1AvatarSpot, p2AvatarSpot;
    CCLabelTTF *turnLabel;
    Puzzle *currentPuzzle;
}

@property (nonatomic, retain) NSMutableArray *player1Pieces;
@property (nonatomic, retain) NSMutableArray *player2Pieces;
@property (nonatomic, retain) NSMutableArray *allPositions;

+ (CCScene *) sceneFromWorld: (int) world AndLevel: (int) level;
+ (CCScene *) sceneFromPuzzle : (Puzzle *) puzzle;
+ (CCScene *) sceneFromGame : (PFObject *) gameObj isPlayer1: (BOOL) p1;
+ (CCScene *) sceneFromMemory : (int) gameNumber;
+ (CCScene *) sceneWithDifficulty : (int) difficulty andSprite: (int) sprite1 onBoard: (int) boardSize;
+ (CCScene *) sceneWithPlayer1Sprite: (int) sprite1 andPlayer2Sprite: (int) sprite2 onBoard: (int) boardSize;
@end
