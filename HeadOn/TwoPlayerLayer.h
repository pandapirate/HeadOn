//
//  TwoPlayerLayer.h
//  Head On
//
//  Created by Kevin Huang on 1/27/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCScrollLayer.h"

@interface TwoPlayerLayer : CCLayerColor {
    CCScrollLayer *player1Piece;
    CCScrollLayer *player2Piece;
    
    UISegmentedControl *boardSizeControl;
    NSMutableArray *pieces1, *pieces2;
    
    int touchHeight;
}

+(CCScene *) scene;

@end
