//
//  Game.m
//  Head On
//
//  Created by Kevin Huang on 2/10/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import "Game.h"

@implementation Game

- (id) init {
    return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder {
    [encoder encodeBool:_isPlayer1 forKey:@"isplayer1"];
    [encoder encodeInt:_gameNumber forKey:@"gameNumber"];
    [encoder encodeInt:_difficulty forKey:@"difficulty"];
    [encoder encodeInt:_p1Sprite forKey:@"p1Sprite"];
    [encoder encodeInt:_p2Sprite forKey:@"p2Sprite"];
    [encoder encodeInt:_p1Score forKey:@"p1Score"];
    [encoder encodeInt:_p2Score forKey:@"p2Score"];
    [encoder encodeObject:_p1Name forKey:@"p1Name"];
    [encoder encodeObject:_p2Name forKey:@"p2Name"];
    [encoder encodeObject:_gameBoard forKey:@"gameBoard"];
    [encoder encodeCGPoint:_from forKey:@"From"];
    [encoder encodeCGPoint:_to forKey:@"To"];
//    NSLog(@"Total Length, %i", _gameBoard.count);
}

- (id) initWithCoder: (NSCoder *) decoder {
    self = [super init];
    if (self) {
        self.isPlayer1 = [decoder decodeBoolForKey:@"isplayer1"];
        self.gameNumber = [decoder decodeIntForKey:@"gameNumber"];
        self.difficulty = [decoder decodeIntForKey:@"difficulty"];
        self.p1Sprite = [decoder decodeIntForKey:@"p1Sprite"];
        self.p2Sprite = [decoder decodeIntForKey:@"p2Sprite"];
        self.p1Score = [decoder decodeIntForKey:@"p1Score"];
        self.p2Score = [decoder decodeIntForKey:@"p2Score"];
        self.p1Name = [decoder decodeObjectForKey:@"p1Name"];
        self.p2Name = [decoder decodeObjectForKey:@"p2Name"];
        self.gameBoard = [[decoder decodeObjectForKey:@"gameBoard"] mutableCopy];
        self.from = [decoder decodeCGPointForKey:@"From"];
        self.to = [decoder decodeCGPointForKey:@"To"];
    }
    return self;
}

@end
