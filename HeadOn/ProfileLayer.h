//
//  AchievementsLayer.h
//  Head On
//
//  Created by Kevin Huang on 1/31/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AutoScrollLabel.h"

@interface ProfileLayer : CCLayerColor {
    int popUp;
    CCMenuItem *admin;
    AutoScrollLabel *nameLabel;
    PFObject *playerData;
}
+(CCScene *) scene;
@end
