//
//  InvitationLayer.m
//  Head On
//
//  Created by Kevin Huang on 2/12/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import "InvitationLayer.h"
#import "InviteCell.h"
#import <Parse/Parse.h>

@implementation InvitationLayer

+ (CCScene *) scene {
    CCScene *scene = [CCScene node];
    InvitationLayer *layer = [[InvitationLayer alloc] init];
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
        [[GameLogic sharedGameLogic] createBarItem:@"Invitations"];
        
        inviteTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, size.height-104) style:UITableViewStylePlain];
        [inviteTable setDelegate:self];
        [inviteTable setDataSource:self];
        [inviteTable setOpaque:NO];
        [inviteTable setBackgroundColor:[UIColor clearColor]];
        [[[CCDirector sharedDirector] view] addSubview:inviteTable];
        
        [self loadRequests];
        
        ///////set up EGO
        if (_refreshHeaderView == nil) {
            
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - inviteTable.bounds.size.height, 320, inviteTable.bounds.size.height) arrowImageName:@"grayArrow.png" textColor:[UIColor colorWithWhite: 0.30 alpha:1] ];
            view.delegate = self;
            [inviteTable addSubview:view];
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
    NSString *message = @"";
    
    switch (section) {
        case 0:
            message = @"Requests Received";
            break;
        default:
            break;
    }
    
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
    switch (section) {
        case 0:
            return 0;
        case 1:
            return [received count];
        default:
            break;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InviteCell *cell = nil;
    UIView *blankView = nil;
    
    if (cell == nil){
        NSArray *noob = [[NSBundle mainBundle] loadNibNamed:@"InviteCell" owner:self options:nil];
        cell = (InviteCell *) [noob objectAtIndex:0];
        blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
        [blankView setBackgroundColor:[UIColor clearColor]];
    }
    
    cell.selectedBackgroundView = blankView;
    PFObject *selectedGame = nil;
    PFObject *oppData = nil;
    switch (indexPath.section) {
        case 0:
            return cell;
        case 1: {
            selectedGame = [received objectAtIndex:indexPath.row];
            oppData = [selectedGame objectForKey:@"Player1"];
            
            cell.LevelLabel.text = [NSString stringWithFormat:@"Lv. %i", [[GameLogic sharedGameLogic] calculateLevel:[[oppData objectForKey:@"Experience"] intValue]]];
            
            cell.NameLabel.font = [UIFont fontWithName:@"BoisterBlack" size:20];
            cell.NameLabel.textColor = [UIColor blackColor];
            cell.NameLabel.text = [oppData objectForKey:@"DisplayName"];
        
            cell.game = selectedGame;
            cell.parentDataSet = received;
            cell.parentTableView = inviteTable;
            
            break;
        }
        default:
            break;
    }

    return cell;
}

- (void) loadRequests {
    received = [[NSMutableArray alloc] init];
    PFObject *curData = [GameLogic sharedGameLogic].playerData;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Player2 = %@", curData];
    PFQuery *query = [PFQuery queryWithClassName:@"Game" predicate:predicate];
    [query whereKey:@"CanStart" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"Ended" equalTo:[NSNumber numberWithBool:NO]];
    [query includeKey:@"Player1"];
    [query includeKey:@"Player2"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Number of Requests found: %i", [objects count]);
            [received addObjectsFromArray:objects];
            [inviteTable reloadData];
        }
    }];
}

//////////////////////////begin of EGO
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	//load data here
    [self loadRequests];
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	
	//  model will automatic call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:inviteTable];
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
