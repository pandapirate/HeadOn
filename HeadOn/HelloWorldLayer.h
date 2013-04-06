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
    CCMenuItem *play, *resume, *invitation, *profile;
    CCMenuItem *soundToggle, *musicToggle;
    CCNode *popupMenu, *tutorialMenu;
}
+(CCScene *) scene;

@end
