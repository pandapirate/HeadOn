//
//  PuzzleManager.m
//  Head On
//
//  Created by Kevin Huang on 4/9/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import "PuzzleManager.h"

@implementation PuzzleManager
static PuzzleManager *sharedPuzzleManager = nil;

+ (PuzzleManager*) sharedPuzzleManager {
    if (sharedPuzzleManager == nil) {
        sharedPuzzleManager = [[super allocWithZone:NULL] init];
    }
    return sharedPuzzleManager;
}

- (Puzzle *) getPuzzleForWorld: (int) world AndLevel: (int) level {
    NSString *key = [NSString stringWithFormat:@"%i-%i", world, level];
    NSData *encodedGame = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return (Puzzle *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedGame];
}

- (BOOL) isLevelEnabledForWorld: (int) world AndLevel: (int) level {
    Puzzle *puz;
    
    if (level > 1)
        puz = [self getPuzzleForWorld:world AndLevel:level-1];
    else if (world > 1)
        puz = [self getPuzzleForWorld:world-1 AndLevel:15];
    else
        return YES;
    
    if (puz.earnedScore > 0)
        return YES;
    else
        return NO;
}

- (int) calculateStarsForWorld: (int) world AndLevel: (int) level  {
    Puzzle *puz = [self getPuzzleForWorld:world AndLevel:level];
    return [self calculateStarsForPuzzle:puz];
}

- (int) calculateStarsForPuzzle: (Puzzle *) puzzle {
    double percent = puzzle.earnedScore * 1.0/puzzle.totalScore;
//    NSLog(@"Earned: %i, Total: %i, Percent: %f", puzzle.earnedScore, puzzle.totalScore, percent);
    int stars = 0;
    if (percent >= 0.90) {
        stars += 3;
    } else if (percent >= 0.7) {
        stars += 2;
    } else if (percent >= 0.3) {
        stars += 1;
    }
    
    return stars;
}

- (int) calculateStarsForWorld: (int) world {
    int stars = 0;
    
    for (int i = 1; i <= 15; i++) {
        stars += [self calculateStarsForWorld:world AndLevel:i];
    }
    
    return stars;
}

- (int) calculatePointForWorld: (int) world {
    int pts = 0;
    
    for (int i = 1; i <= 15; i++) {
        Puzzle *puz = [self getPuzzleForWorld:world AndLevel:i];
        pts += puz.earnedScore;
    }
    
    return pts;
}

- (CCNode *) drawStars: (int) number {
    CCNode *stars = [[CCNode alloc] init];
    stars.contentSize = CGSizeMake(30, 20);
    
    // first star
    CCSprite *sp1;
    if (number > 0) {
        sp1 = [[CCSprite alloc] initWithFile:@"star.png"];
    } else {
        sp1 = [[CCSprite alloc] initWithFile:@"star-blank.png"];
    }
    sp1.scale = 0.2;
    sp1.position = ccp(7,8);
    
    // second star
    CCSprite *sp2;
    if (number > 1) {
        sp2 = [[CCSprite alloc] initWithFile:@"star.png"];
    } else {
        sp2 = [[CCSprite alloc] initWithFile:@"star-blank.png"];
    }
    sp2.scale = 0.2;
    sp2.position = ccp(15,11);
    
    // third star
    CCSprite *sp3;
    if (number > 2) {
        sp3 = [[CCSprite alloc] initWithFile:@"star.png"];
    } else {
        sp3 = [[CCSprite alloc] initWithFile:@"star-blank.png"];
    }
    sp3.scale = 0.2;
    sp3.position = ccp(23,8);
    
    [stars addChild:sp1];
    [stars addChild:sp2];
    [stars addChild:sp3];
    
    return stars;
}

- (void) initiatePuzzles {
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"1-1"]) {
//        return;
//    }
    
    for (int world = 1; world <= 4; world++) {
        for (int level = 1; level <= 15; level++) {
            [self setPuzzleForWorld:world AndLevel:level];
        }
    }
}

- (void) setPuzzleForWorld: (int) world AndLevel: (int) level {
    NSString *key = [NSString stringWithFormat:@"%i-%i", world, level];
    Puzzle *puz = [[Puzzle alloc] init];
    
    puz.earnedScore = 0;
    puz.world = world;
    puz.level = level;
    
    NSMutableArray *board = [[NSMutableArray alloc] init];
    switch (world) {
        case 1: {
            switch (level) {
                case 1: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"2", nil]];
                    
                    puz.turns = 1;
                    break;
                }
                case 2: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", nil]];
                    
                    puz.turns = 1;
                    break;
                }
                case 3: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"1", @"0", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", nil]];
                    
                    puz.turns = 1;
                    break;
                }
                case 4: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"2", @"0", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", nil]];
                    
                    puz.turns = 1;
                    break;
                }
                case 5: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"2", @"0", nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 6: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"2", @"0", nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 7: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"1", @"0", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"0", @"0", nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 8: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"2", @"0", @"0", nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 9: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 10: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", nil]];
                    puz.turns = 2;
                    break;
                }
                case 11: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"1", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"2", @"0", nil]];                    
                    puz.turns = 2;
                    break;
                }
                case 12: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"2", @"0", nil]];                    
                    puz.turns = 2;
                    break;
                }
                case 13: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"0", @"1", nil]];
                    puz.turns = 2;
                    break;
                }
                case 14: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"2", nil]];
                    puz.turns = 2;
                    break;
                }
                case 15: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", nil]];
                    puz.turns = 2;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 2: {
            switch (level) {
                case 1: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"0", nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 2: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"2", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"0", nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 3: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"1", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 4: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"2", @"0", @"0", nil]];
                    
                    puz.turns = 4;
                    break;
                }
                case 5: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"0", @"2", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 6: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 7: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"0", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"0", @"1", nil]];
                    
                    puz.turns = 3;
                    break;
                }
                case 8: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"1", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    
                    puz.turns = 3;
                    break;
                }
                case 9: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    
                    puz.turns = 3;
                    break;
                }
                case 10: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", nil]];
                    
                    puz.turns = 3;
                    break;
                }
                case 11: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"2", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"1", @"2", nil]];
                    
                    puz.turns = 3;
                    break;
                }
                case 12: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"0", @"1", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"1", @"0", nil]];
                    
                    puz.turns = 4;
                    break;
                }
                case 13: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"2", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"0", nil]];
                    
                    puz.turns = 4;
                    break;
                }
                case 14: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"1", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"0", nil]];
                    
                    puz.turns = 3;
                    break;
                }
                case 15: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    
                    puz.turns = 3;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 3: {
            switch (level) {
                case 1: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"1", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"1", nil]];
                    
                    puz.turns = 3;
                    break;
                }
                case 2: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"0", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    
                    puz.turns = 3;
                    break;
                }
                case 3: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"0", @"0", nil]];
                    
                    puz.turns = 4;
                    break;
                }
                case 4: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"2", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"1", nil]];
                    
                    puz.turns = 4;
                    break;
                }
                case 5: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"0", @"0", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"1", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    
                    puz.turns = 4;
                    break;
                }
                case 6: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"0", @"0", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"1", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    
                    puz.turns = 4;
                    break;
                }
                case 7: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"2", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    
                    puz.turns = 4;
                    break;
                }
                case 8: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", nil]];
                    
                    puz.turns = 4;
                    break;
                }
                case 9: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"0", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"1", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"0", @"2", nil]];
                    
                    puz.turns = 4;
                    break;
                }
                case 10: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"1", @"0", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"0", @"1", nil]];
                    
                    puz.turns = 4;
                    break;
                }
                case 11: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"2", @"0", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"1", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"2", nil]];
                    
                    puz.turns = 4;
                    break;
                }
                case 12: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"0", @"0", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", nil]];
                    
                    puz.turns = 5;
                    break;
                }
                case 13: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"0", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"2", @"0", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", nil]];
                    
                    puz.turns = 5;
                    break;
                }
                case 14: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"1", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"1", nil]];
                    
                    puz.turns = 7;
                    break;
                }
                case 15: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"2", @"0", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"2", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"1", @"0", @"1", nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"1", @"0", nil]];
                    
                    puz.turns = 5;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 4: {
            switch (level) {
                case 1: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"1", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", @"0",nil]];
                    
                    puz.turns = 1;
                    break;
                }
                case 2: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", @"1",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"1", @"1", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"2", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 3: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"1", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"2", @"2", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 4: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"1", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"0", @"1", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"2", @"0", @"2",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 5: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"0", @"0", @"1",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"1", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"2", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", @"0",nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 6: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"2", @"1", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"0", @"2", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"2", @"0", @"0",nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 7: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"0", @"1", @"2", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"2", @"2",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"2", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 8: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"2", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"1", @"0", @"2", @"2",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"2", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"2", @"0", @"0",nil]];
                    
                    puz.turns = 3;
                    break;
                }
                case 9: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"1", @"2", @"2", @"2", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"1", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", @"0",nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 10: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"1", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"2", @"1",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", @"0",nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 11: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"2", @"1", @"0", @"1",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"1", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"2", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    
                    puz.turns = 3;
                    break;
                }
                case 12: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"2", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"1", @"2",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"0", @"0",nil]];
                    
                    puz.turns = 2;
                    break;
                }
                case 13: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"2", @"2", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"2", @"1", @"2", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"1", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"0", @"1", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", @"0",nil]];
                    
                    puz.turns = 3;
                    break;
                }
                case 14: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"0", @"0", @"2", @"1",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"1", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"1", @"1", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"1", @"0",nil]];
                    
                    puz.turns = 3;
                    break;
                }
                case 15: {
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"1", @"0", @"1",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"2", @"1", @"0", @"1", @"2",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"2", @"2", @"0",nil]];
                    [board addObject:[[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0",nil]];
                    
                    puz.turns = 2;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    int total = 0;
    
    for (NSMutableArray *row in board) {
        for (NSString *str in row) {
            if ([str intValue] == 2) {
                total++;
            }
        }
    }
    
    puz.totalScore = (total-1) * 2500;
    puz.piecePositions = board;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:puz] forKey:key];
}

@end
