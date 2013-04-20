//
//  Puzzle.h
//  Head On
//
//  Created by Kevin Huang on 4/9/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Puzzle : NSObject
{
    
    
}

@property (nonatomic) int world;
@property (nonatomic) int level;
@property (nonatomic, retain) NSMutableArray *piecePositions;
@property (nonatomic) int totalScore;
@property (nonatomic) int earnedScore;
@property (nonatomic) int turns;

@end
