//
//  OnlinePlayerLayer.h
//  Head On
//
//  Created by Kevin Huang on 1/29/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "EGORefreshTableHeaderView.h"

@interface OnlinePlayerLayer : CCLayer <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate>
{
    UITableView *playersTable;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}

@property (nonatomic, retain) NSMutableArray *players;
+(CCScene *) scene;
@end
