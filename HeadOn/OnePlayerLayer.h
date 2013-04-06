//
//  OnePlayerLayer.h
//  Head On
//
//  Created by Kevin Huang on 1/27/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCScrollLayer.h"

@interface OnePlayerLayer : CCLayerColor
{
    int difficulty;
    CCLabelTTF *difficultyLabel;
    UISegmentedControl *difficultyControl;
    UISegmentedControl *boardSizeControl;
    CCScrollLayer *avatarScroll;
    NSMutableArray *pieces;
    
    int touchHeight;
}


+(CCScene *) scene;

@end
