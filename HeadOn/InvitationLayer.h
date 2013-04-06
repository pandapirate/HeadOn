//
//  InvitationLayer.h
//  Head On
//
//  Created by Kevin Huang on 2/12/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "EGORefreshTableHeaderView.h"

@interface InvitationLayer : CCLayer <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate>
{
    UITableView *inviteTable;
    NSMutableArray *received;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}

+(CCScene *) scene;

@end
