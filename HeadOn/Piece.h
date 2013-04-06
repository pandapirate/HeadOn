//
//  Piece.h
//  Head On
//
//  Created by Kevin Huang on 1/29/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Position.h"
#import "cocos2d.h"


@interface Piece : NSObject
{
    CGPoint armCoordL, armCoordR, legCoordL, legCoordR, bodyCoord, sideFootCoord, sideArmCoord;
    CCTexture2D *handTexture; 
    CCTexture2D *footTexture;
    BOOL isMoving;
}

@property (nonatomic, retain) Position *p;
@property (nonatomic, retain) CCSprite *sprite;

//Moving Piece Objects
@property (nonatomic, retain) CCNode *group;

@property (nonatomic, retain) CCSprite *loss;
@property (nonatomic, retain) CCSprite *body;
@property (nonatomic, retain) CCSprite *side;
@property (nonatomic, retain) CCSprite *back;
@property (nonatomic, retain) CCSprite *armL;
@property (nonatomic, retain) CCSprite *armR;
@property (nonatomic, retain) CCSprite *legL;
@property (nonatomic, retain) CCSprite *legR;

- (CCNode *) createSprite: (int) number;
- (void) jump: (int) number;
- (void) walkRight: (int) number;
- (void) walkLeft: (int) number;
- (void) walkDown: (int) number;
- (void) walkUp: (int) number;
- (void) getCaptured;

- (void) faceRight;
- (void) faceLeft;
- (void) faceDown;
- (void) faceUp;
- (void) showLoss;

- (void) reset: (CGPoint) point;
@end
