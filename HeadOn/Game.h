//
//  Game.h
//  Head On
//
//  Created by Kevin Huang on 2/10/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Position.h"

@interface Game : NSObject

@property (nonatomic, retain) NSMutableArray *gameBoard;
@property (nonatomic) BOOL isPlayer1;

@property (nonatomic) int difficulty;
@property (nonatomic) int gameNumber;

@property (nonatomic) int p1Sprite;
@property (nonatomic) int p2Sprite;

@property (nonatomic) int p1Score;
@property (nonatomic) int p2Score;

@property (nonatomic, retain) NSString *p1Name;
@property (nonatomic, retain) NSString *p2Name;

@property (nonatomic) CGPoint from;
@property (nonatomic) CGPoint to;
@end 
