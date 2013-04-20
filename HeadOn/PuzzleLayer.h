//
//  PuzzleLayer.h
//  Head On
//
//  Created by Kevin Huang on 4/7/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCScrollLayer.h"

@interface PuzzleLayer : CCLayer {
    CCScrollLayer *worldScroller;
    CGPoint beginningLocation;
}

+ (CCScene *) sceneWithPageNumber: (int) page;
@end
