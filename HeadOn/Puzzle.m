//
//  Puzzle.m
//  Head On
//
//  Created by Kevin Huang on 4/9/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import "Puzzle.h"

@implementation Puzzle

- (id) init {
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    [encoder encodeInt:_world forKey:@"world"];
    [encoder encodeInt:_level forKey:@"level"];
    [encoder encodeInt:_totalScore forKey:@"totalScore"];
    [encoder encodeInt:_earnedScore forKey:@"earnedScore"];
    [encoder encodeInt:_turns forKey:@"turns"];
    [encoder encodeObject:_piecePositions forKey:@"piecePosition"];
}

- (id) initWithCoder: (NSCoder *) decoder {
    self = [super init];
    if (self) {
        self.world = [decoder decodeIntForKey:@"world"];
        self.level = [decoder decodeIntForKey:@"level"];
        self.totalScore = [decoder decodeIntForKey:@"totalScore"];
        self.earnedScore = [decoder decodeIntForKey:@"earnedScore"];
        self.turns = [decoder decodeIntForKey:@"turns"];
        self.piecePositions = [[decoder decodeObjectForKey:@"piecePosition"] mutableCopy];
    }
    return self;
}


@end
