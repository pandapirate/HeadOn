//
//  AchievementsLayer.m
//  Head On
//
//  Created by Kevin Huang on 1/31/13.
//  Copyright 2013 The Company. All rights reserved.
//

#import "ProfileLayer.h"
#import "GameLogic.h"
#import <Parse/Parse.h>

@implementation ProfileLayer
+ (CCScene *) scene {
    CCScene *scene = [CCScene node];
    ProfileLayer *layer = [[ProfileLayer alloc] init];
    [scene addChild:layer];
    return scene;
}

- (id) init {
    if ((self = [super init])) {
        
        if ([[GameLogic sharedGameLogic] networkReachable]) {
            PFQuery *query = [PFQuery queryWithClassName:@"PlayerData"];
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            [GameLogic sharedGameLogic].playerData = [query getFirstObject];
        }

        CGSize size = [[CCDirector sharedDirector] winSize];
        [[GameLogic sharedGameLogic] showBars];
        
        CCSprite *bg;
        
        if (IS_IPHONE4)
            bg = [CCSprite spriteWithFile:@"bg-iphone4.png"];
        else
            bg = [CCSprite spriteWithFile:@"bg-iphone5.png"];
        
        bg.position = ccp(size.width/2, size.height/2);
        [self addChild:bg];
        
        [[GameLogic sharedGameLogic] createBarItem:@"Profile"];

        NSString *name = @"Anonymous";
        
        playerData = [GameLogic sharedGameLogic].playerData;
        NSLog(@"The Data: %@", playerData);
        
        if ([[playerData objectForKey:@"DisplayName"] length] > 0) {
            name = [playerData objectForKey:@"DisplayName"];
        }
        
        CCLabelTTF *displayLabel = [CCLabelTTF labelWithString:@"Display Name:" fontName:@"Vanilla Whale" fontSize:32];
        displayLabel.position = ccp(83, size.height - 70);
        displayLabel.color = ccc3(0, 0, 0);
        [self addChild:displayLabel];
        
        nameLabel = [[AutoScrollLabel alloc] init];
        nameLabel.font = [UIFont fontWithName:@"Vanilla Whale" size:44];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.frame = CGRectMake(15, 85, 230, 44);
        [[[CCDirector sharedDirector] view] addSubview:nameLabel];
        
        nameLabel.text = name;

        int level = [[playerData objectForKey:@"Experience"] intValue];
        NSString *levelText = [NSString stringWithFormat:@"Level: %i", [[GameLogic sharedGameLogic] calculateLevel:level]];
        if (![[GameLogic sharedGameLogic] networkReachable])
            levelText = @"Level: N/A";
        
        UILabel *levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 135, 125, 30)];
        levelLabel.font = [UIFont fontWithName:@"Vanilla Whale" size:32];
        levelLabel.text = levelText;
        levelLabel.textColor = [UIColor blackColor];
        levelLabel.backgroundColor = [UIColor clearColor];
        [[[CCDirector sharedDirector] view] addSubview:levelLabel];
        
        CCNode *levelPic = [[GameLogic sharedGameLogic] levelDisplay:level];
        levelPic.position = ccp(15, size.height - 200);
        [self addChild:levelPic];
        
        UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(275, 80, 40, 40)];
        [editBtn setBackgroundImage:[UIImage imageNamed:@"editicon.png"] forState:UIControlStateNormal];
        [editBtn addTarget:self action:@selector(changeName) forControlEvents:UIControlEventTouchUpInside];
        [[[CCDirector sharedDirector] view] addSubview:editBtn];
        
        [self generateLabelWithText:@"Local Stats" atPosition:CGRectMake(15, 210, 200, 30) withSize:40 andTag:1];
        [self generateLabelWithText:@"Online Stats" atPosition:CGRectMake(15, 310, 200, 30) withSize:40 andTag:1];
        
        [self generateLabelWithText:@"Wins-Losses" atPosition:CGRectMake(100, 240, 200, 30) withSize:32 andTag:1];
        [self generateLabelWithText:@"Win Percent" atPosition:CGRectMake(100, 270, 200, 30) withSize:32 andTag:1];
        
        [self generateLabelWithText:@"Wins-Losses" atPosition:CGRectMake(100, 340, 200, 30) withSize:32 andTag:1];
        [self generateLabelWithText:@"Win Percent" atPosition:CGRectMake(100, 370, 200, 30) withSize:32 andTag:1];
        
        int localTotal = [[NSUserDefaults standardUserDefaults] integerForKey:@"Local_Total"];
        int localWins = [[GCHelper sharedInstance] totalWins];
        
        int onlineTotal = [[playerData objectForKey:@"OnlineTotal"] intValue];
        int onlineWins = [[playerData objectForKey:@"OnlineWins"] intValue];
        
        NSString *localStat = [NSString stringWithFormat:@"%i-%i", localWins, (localTotal - localWins)];
        NSString *onlineStat = [NSString stringWithFormat:@"%i-%i", onlineWins, (onlineTotal - onlineWins)];
        if (![[GameLogic sharedGameLogic] networkReachable])
            onlineStat = @"N/A";
        
        [self generateLabelWithText:localStat atPosition:CGRectMake(230, 240, 80, 30) withSize:32 andTag:10];
        [self generateLabelWithText:onlineStat atPosition:CGRectMake(230, 340, 80, 30) withSize:32 andTag:11];
        
        localStat = [NSString stringWithFormat:@"%.2f%%", (localTotal > 0 ? 100.0 *localWins/localTotal : 0.0)];
        onlineStat = [NSString stringWithFormat:@"%.2f%%", (onlineTotal > 0 ? 100.0 * onlineWins /onlineTotal : 0.0)];

        if (![[GameLogic sharedGameLogic] networkReachable])
            onlineStat = @"N/A";
        
        [self generateLabelWithText:localStat atPosition:CGRectMake(230, 270, 100, 30) withSize:32 andTag:10];
        [self generateLabelWithText:onlineStat atPosition:CGRectMake(230, 370, 100, 30) withSize:32 andTag:11];
        
        CCMenu *startMenu = [CCMenu menuWithItems:admin, nil];
        startMenu.tag = 123;
        startMenu.position = CGPointZero;
        [self addChild:startMenu];
    }
    return self;
}

- (void) generateLabelWithText: (NSString *) text atPosition: (CGRect) rec withSize: (int) size andTag: (int) tag{
    
    UILabel *label = [[UILabel alloc] initWithFrame: rec];
    [label setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
    [label setTag: tag];
    [label setText:text];
    [label setFont:[UIFont fontWithName:@"Vanilla Whale" size:size]];
    [[[CCDirector sharedDirector] view] addSubview:label];
}

- (CCMenuItem *) generateMenuItem: (NSString *) text atPosition: (CGPoint) p withSelector: (SEL) sel{
    
    CCMenuItem *temp = [CCMenuItemImage itemWithNormalImage:@"green_up.png" selectedImage:@"green_down.png" target:self selector:sel];
    temp.position = p;
    temp.scale = 1.5;
    
    CCLabelTTF *one = [CCLabelTTF labelWithString:text fontName:@"Vanilla Whale" fontSize:24];
    one.color = ccc3(0, 0, 0);
    one.position = ccp(temp.contentSize.width/2, temp.contentSize.height/2);
    [temp addChild:one];
    
    return temp;
}

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *temp = [[alertView textFieldAtIndex:0] text];
        NSLog(@"Change Name to %@", temp);
        
        if ([temp length] > 0) {
            [playerData setObject:temp forKey:@"DisplayName"];
            [playerData saveInBackground];
            
            nameLabel.text = temp;
        }
    }
}

- (void) changeName {
    UIAlertView *nameChanger = [[UIAlertView alloc] initWithTitle:@"New Display Name" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    nameChanger.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *newNameField = [nameChanger textFieldAtIndex:0];
    newNameField.placeholder = @"New Name";
    newNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [nameChanger show];
}

- (void) userLogOut {
    [PFUser logOut];
    [[GameLogic sharedGameLogic] popViews];
    [[CCDirector sharedDirector] popScene];
}

- (void) returnToMenu {
    [[GameLogic sharedGameLogic] popViews];
    [[CCDirector sharedDirector] popScene];
}

@end
