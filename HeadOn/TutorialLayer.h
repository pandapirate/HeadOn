//
//  TutorialLayer.h
//  Head On
//
//  Created by Kevin Huang on 1/31/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCScrollLayer.h"

@interface TutorialLayer : CCLayer {
    CCScrollLayer *pageScroll;
}
+(CCScene *) sceneWithTutorial: (int) tutorialNumber exitTo: (int) exitNumber;
@end
