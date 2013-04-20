//
//  PuzzleLevelLayer.h
//  Head On
//
//  Created by Kevin Huang on 4/9/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PuzzleLevelLayer : CCLayer {
    int world;
    NSMutableArray *menuItems;
}
+ (CCScene *) sceneWithWorld: (int) world;
+ (CCScene *) sceneWithPage: (int) page;
@end
