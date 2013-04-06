//
//  OnlinePlayerLayer.m
//  Head On
//
//  Created by Kevin Huang on 1/29/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import "OnlinePlayerLayer.h"
#import "PlayerCell.h"
#import <Parse/Parse.h>

@implementation OnlinePlayerLayer
@synthesize players;

+ (CCScene *) scene {
    CCScene *scene = [CCScene node];
    OnlinePlayerLayer *layer = [[OnlinePlayerLayer alloc] init];
    [scene addChild:layer];
    return scene;
}

- (id) init {
    if ((self = [super init])) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *bg;
        
        if (IS_IPHONE4)
            bg = [CCSprite spriteWithFile:@"bg-iphone4.png"];
        else
            bg = [CCSprite spriteWithFile:@"bg-iphone5.png"];
        
        bg.position = ccp(size.width/2, size.height/2);
        [self addChild:bg];
        
        [[GameLogic sharedGameLogic] showBars];
        
        [[GameLogic sharedGameLogic] createBarItem:@"Multiplayer"];

        [self loadPlayers];
        
        playersTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, size.height-104) style:UITableViewStylePlain];
        [playersTable setDelegate:self];
        [playersTable setDataSource:self];
        [playersTable setOpaque:NO];
        [playersTable setBackgroundColor:[UIColor clearColor]];
        
        [[[CCDirector sharedDirector] view] addSubview:playersTable];
        
        ///////set up EGO
        if (_refreshHeaderView == nil) {
            
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - playersTable.bounds.size.height, 320, playersTable.bounds.size.height) arrowImageName:@"grayArrow.png" textColor:[UIColor colorWithWhite: 0.30 alpha:1] ];
            view.delegate = self;
            [playersTable addSubview:view];
            _refreshHeaderView = view;
        }
        //  update the last update date
        [_refreshHeaderView refreshLastUpdatedDate];
        ///////end of EGO setup
    }
    return self;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 35;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSString *message = @"Recent Players";
    if (section == 1)
        message = @"";
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.font = [UIFont fontWithName:@"BoisterBlack" size:20];
    headerLabel.frame = CGRectMake(5, 5, 310, 30);
    
    headerLabel.text = message;
    [customView addSubview:headerLabel];
    return customView;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 0;
    else
        return [players count];;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PlayerCell *cell = nil;
    UIView *blankView = nil;
    if (cell == nil){
        NSArray *noob = [[NSBundle mainBundle] loadNibNamed:@"PlayerCell" owner:self options:nil];
        cell = (PlayerCell *) [noob objectAtIndex:0];
        blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        [blankView setBackgroundColor:[UIColor clearColor]];
    }
    
    [cell setOpaque:NO];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    if (players.count == 0)
        return cell;
    
    PFObject *playerData = [players objectAtIndex:indexPath.row];
    UIFont *font = [UIFont fontWithName:@"BoisterBlack" size:20];
    
    cell.PlayerName.text = [playerData objectForKey:@"DisplayName"];
    
    int exp = [[GameLogic sharedGameLogic] calculateLevel:[[playerData objectForKey:@"Experience"] intValue]];
    cell.PlayerLevel.text = [NSString stringWithFormat:@"Lv. %i", exp];
    
    cell.selectedBackgroundView = blankView;
    cell.user = playerData;
    cell.PlayerName.font = font;
    cell.PlayerName.textColor = [UIColor blackColor];
    return cell;
}

- (void) loadPlayers {
    players = [[NSMutableArray  alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"PlayerData"];
    [query orderByDescending:@"updatedAt"];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *x in objects) {
                if ([x.objectId isEqualToString:[GameLogic sharedGameLogic].playerData.objectId]) {
                    NSLog(@"Found same Object");
                    continue;
                }
                [players addObject:x];
            }
            [playersTable reloadData];
        } else {
            NSLog(@"Error, %@", error.localizedDescription);
        }
        
//        NSLog(@"Number: %i", players.count);
    }];
    

}

//////////////////////////begin of EGO
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	//load data here
    [self loadPlayers];
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	
	//  model will automatic call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:playersTable];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
//////////////////////////end of EGO

@end
