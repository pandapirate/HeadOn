//
//  PuzzleManager.h
//  Head On
//
//  Created by Kevin Huang on 4/9/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Puzzle.h"

@interface PuzzleManager : NSObject
+ (PuzzleManager*) sharedPuzzleManager;

- (void) initiatePuzzles;
- (Puzzle *) getPuzzleForWorld: (int) world AndLevel: (int) level;
- (int) calculateStarsForWorld: (int) world AndLevel: (int) level;
- (int) calculateStarsForPuzzle: (Puzzle *) puzzle;
- (int) calculateStarsForWorld: (int) world;
- (int) calculatePointForWorld: (int) world;
- (BOOL) isLevelEnabledForWorld: (int) world AndLevel: (int) level;
- (CCNode *) drawStars: (int) number;
@end
