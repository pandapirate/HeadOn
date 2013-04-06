//
//  ResumeLayer.h
//  Head On
//
//  Created by Kevin Huang on 2/10/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "EGORefreshTableHeaderView.h"

@interface ResumeLayer : CCLayer <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate>
{
    UITableView *gamesTable;
    NSMutableArray *localGames, *onlineGames;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}
+(CCScene *) scene;
@end
