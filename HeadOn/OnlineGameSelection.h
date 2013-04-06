//
//  OnlineGameSelection.h
//  Head On
//
//  Created by Kevin Huang on 2/12/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCScrollLayer.h"
#import "Game.h"

@interface OnlineGameSelection : CCLayer {
    BOOL startedGame;
    PFObject *opponent;
    CCScrollLayer *avatarScroll;
    UISegmentedControl *boardSizeControl;
    NSMutableArray *pieces;
    PFObject *GameObject;
    Game *theGame;
    
    int touchHeight;
}
+(CCScene *) sceneWithPlayer: (PFObject *) user;
+(CCScene *) sceneWithGame: (PFObject *) game;
@end
