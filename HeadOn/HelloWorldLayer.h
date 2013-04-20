//
//  HelloWorldLayer.h
//  HeadOn
//
//  Created by Kevin Huang on 1/26/13.
//  Copyright The Company 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor <UITabBarDelegate, GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    CCMenuItem *puzzles, *play, *multiplayer, *profile;
    CCMenuItem *soundToggle, *musicToggle;
    CCNode *classicMenu, *tutorialMenu, *multiMenu;
}
+(CCScene *) scene;

@end
