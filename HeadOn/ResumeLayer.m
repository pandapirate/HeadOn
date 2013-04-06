//
//  ResumeLayer.m
//  Head On
//
//  Created by Kevin Huang on 2/10/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import "ResumeLayer.h"
#import "GameLogic.h"
#import "GameLayer.h"
#import "GameCell.h"
#import "Game.h"
#import <Parse/Parse.h>


@implementation ResumeLayer

+ (CCScene *) scene {
    CCScene *scene = [CCScene node];
    ResumeLayer *layer = [[ResumeLayer alloc] init];
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
        [[GameLogic sharedGameLogic] createBarItem:@"Resume"];
        
        gamesTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, size.height-104) style:UITableViewStylePlain];
        [gamesTable setDelegate:self];
        [gamesTable setDataSource:self];
        [gamesTable setOpaque:NO];
        [gamesTable setBackgroundColor:[UIColor clearColor]];
        [[[CCDirector sharedDirector] view] addSubview:gamesTable];
        
        [self loadData];
        
        ///////set up EGO
        if (_refreshHeaderView == nil) {
            
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - gamesTable.bounds.size.height, 320, gamesTable.bounds.size.height) arrowImageName:@"grayArrow.png" textColor:[UIColor colorWithWhite: 0.30 alpha:1] ];
            view.delegate = self;
            [gamesTable addSubview:view];
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
            message = @"Online Games";
            break;
        case 1:
            message = @"Local Games";
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
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return onlineGames.count;
        case 2:
            return localGames.count;
        default:
            break;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GameCell *cell = nil;
    UIView *blankView = nil;
    if (cell == nil){
        NSArray *noob = [[NSBundle mainBundle] loadNibNamed:@"GameCell" owner:self options:nil];
        cell = (GameCell *) [noob objectAtIndex:0];
        blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        [blankView setBackgroundColor:[UIColor clearColor]];
    }
    Game *temp = nil;
    
    switch (indexPath.section) {
        case 2:{
            temp = [localGames objectAtIndex:indexPath.row];
            cell.parentDataSet = localGames;
            break;
        }
        case 1:{
            NSData *encodedGame = [[onlineGames objectAtIndex:indexPath.row] objectForKey:@"Board"];
            temp = (Game *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedGame];
            cell.GameObject = [onlineGames objectAtIndex:indexPath.row];
            cell.parentDataSet = onlineGames;
            break;
        }
        default:
            break;
    }
    [cell setOpaque:NO];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    UIFont *font = [UIFont fontWithName:@"BoisterBlack" size:20];
    cell.selectedBackgroundView = blankView;
    cell.BoardSize.font = font;
    cell.NameLabel.font = font;
    cell.NameLabel.textColor = [UIColor blackColor];
    
    cell.parentTableView = gamesTable;
    cell.selectedRow = indexPath.row;
    
    if (temp.gameNumber)
        cell.gameNumber = temp.gameNumber;
    
    
    NSString *text = @"";

    if (indexPath.section == 1) {
        if ([[[[onlineGames objectAtIndex:indexPath.row] objectForKey:@"Player1"] objectId]
             isEqualToString:[GameLogic sharedGameLogic].playerData.objectId]) {
            text = temp.p2Name;
        } else
            text = temp.p1Name;
        
    } else if (indexPath.section == 2) {
        if (temp.difficulty) {
            text = [self convertToLevel:temp.difficulty];
        } else
            text = [NSString stringWithFormat:@"%@ vs %@", [[GameLogic sharedGameLogic] convertToFighter:temp.p1Sprite], [[GameLogic sharedGameLogic] convertToFighter:temp.p2Sprite] ];
    }
    
    cell.BoardSize.text = [NSString stringWithFormat:@"%ix%i", temp.gameBoard.count, temp.gameBoard.count];
    cell.NameLabel.text = text;
    
    return cell;
}

- (NSString *) convertToLevel: (int) num {
    switch (num) {
        case 2:
            return @"Rookie CPU";
        case 3:
            return @"Regular CPU";
        case 4:
            return @"Veteran CPU";
        case 5:
            return @"Master CPU";
        default:
            break;
    }
    return @"Error";
}



- (void) loadData {
    localGames = [[NSMutableArray alloc] init];
    onlineGames = [[NSMutableArray alloc] init];

    NSString *gameName = @"";
    int counter = 1;
    while (true) {
        gameName = [NSString stringWithFormat:@"Game%i", counter];
        
        NSData *encodedGame = [[NSUserDefaults standardUserDefaults] objectForKey:gameName];
        if (encodedGame) {
            Game *currentGame = (Game *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedGame];
            [localGames addObject:currentGame];
        } else if (counter > 10) {
            break;
        }
        counter++;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Player1 = %@ OR Player2 = %@", [GameLogic sharedGameLogic].playerData, [GameLogic sharedGameLogic].playerData];
    PFQuery *gameQuery = [PFQuery queryWithClassName:@"Game" predicate:predicate];
    [gameQuery includeKey:@"Player1"];
    [gameQuery includeKey:@"Player2"];
    [gameQuery whereKey:@"CanStart" equalTo:[NSNumber numberWithBool:YES]];
    [gameQuery whereKey:@"Ended" equalTo:[NSNumber numberWithBool:NO]];
    [gameQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [onlineGames addObjectsFromArray:objects];
            [gamesTable reloadData];
        }
    }];
    
    [gamesTable reloadData];
}

- (void) goToPlay {
    [[GameLogic sharedGameLogic] popViews];
    [[GameLogic sharedGameLogic] setTabBarSelection:-1];
    [[CCDirector sharedDirector] replaceScene:[GameLayer sceneFromMemory:3]];
}

//////////////////////////begin of EGO
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	//load data here
    [self loadData];
	_reloading = YES;
}

- (void)doneLoadingTableViewData{
	
	//  model will automatic call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:gamesTable];
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
