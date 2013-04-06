//
//  GCHelper.m
//  Head On
//
//  Created by Kevin Huang on 2/18/13.
//  Copyright (c) 2013 The Company. All rights reserved.
//

#import "GCHelper.h"

@implementation GCHelper

static GCHelper *sharedHelper = nil;

static NSString *FourBoard = @"4x4_Board";
static NSString *FiveBoard = @"5x5_Board";
static NSString *SixBoard = @"6x6_Board";
static NSString *Rookie = @"Rookie_Game";
static NSString *Normal = @"Normal_Game";
static NSString *Veteran = @"Veteran_Game";
static NSString *Master = @"Master_Game";
static NSString *Total = @"Total_Game";
static NSString *LocalTotal = @"Local_Total";
static NSString *Solo = @"Solo_Game";
static NSString *HeadToHead = @"Double_Game";
static NSString *MultiPlayer = @"Multi_Game";

+ (GCHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
        
        NSLog(@"Setting Variables");
    }
    return sharedHelper;
}

- (void) authenticateLocalUser {
    

    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    if (gcClass) {
        gcAvailable = YES;
        GKLocalPlayer *local = [GKLocalPlayer localPlayer];
        if (local.authenticated == NO) {
            [local authenticateWithCompletionHandler:nil];
        }
    } else
        gcAvailable = NO;
}

- (void) submitHighScore: (int64_t) score forCategory: (NSString *) category {
    NSLog(@"The Score: %lli", score);
    
    if (!gcAvailable) {
        NSLog(@"Error, no Game Center");
        return;
    }
    
    GKScore *gkScore = [[GKScore alloc] initWithCategory:category];
    
    gkScore.value = score;
    [gkScore reportScoreWithCompletionHandler:^(NSError *error) {
        
        [self setLastError:error];
        BOOL success = (error == nil);
        if ([_delegate respondsToSelector:@selector(onScoresSubmitted:)]) {
            [_delegate onScoresSubmitted:success];
        }
    }];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"]) {
        int oldScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
        if (score > oldScore) {
            [GKNotificationBanner showBannerWithTitle:@"New Highscore" message:[NSString stringWithFormat:@"%lli is a new highscore!", score] completionHandler:nil];
            [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"HighScore"];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"HighScore"];
        [GKNotificationBanner showBannerWithTitle:@"New Highscore" message:[NSString stringWithFormat:@"%lli is a new highscore!", score] completionHandler:nil];
    }
}

- (void) submitAchievement: (NSString *) identifier percentComplete: (double) percent {
    if (achievementCache == nil) {
        [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
            if (!error) {
                NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithCapacity:achievements.count];
                for (GKAchievement *achieve in achievements) {
                    [temp setObject:achieve forKey:achieve.identifier];
                }
                achievementCache = temp;
                [self submitAchievement:identifier percentComplete:percent];
            }
        }];
    } else {
        GKAchievement *achieve = [achievementCache objectForKey:identifier];
        
        if (achieve) {
            if (achieve.percentComplete >= 100 || achieve.percentComplete >= percent) {
                achieve = nil;
            }
            achieve.percentComplete = percent;
        } else {
            achieve = [[GKAchievement alloc] initWithIdentifier:identifier];
            achieve.percentComplete = percent;
            [achievementCache setObject:achieve forKey:identifier];
        }
        
//        NSLog(@"Completed Reporting for achievement: %@ at percent: %f", identifier, percent);
        if (achieve){
            [achieve reportAchievementWithCompletionHandler:^(NSError *error) {
                
                if (percent >= 100.0) {
                    [self presentBanner:identifier];
                }
            }];
        }
    }
}



- (void) checkAchievements {
    int value = 0;

    value = [[NSUserDefaults standardUserDefaults] integerForKey:Total];
    [self submitAchievement:@"HeadOn.FirstTimer" percentComplete:100*(value/1.0)];
    [self submitAchievement:@"HeadOn.FiveTimes" percentComplete:100*(value/5.0)];
    [self submitAchievement:@"HeadOn.10Times" percentComplete:100*(value/10.0)];
    [self submitAchievement:@"HeadOn.25Times" percentComplete:100*(value/25.0)];
    [self submitAchievement:@"HeadOn.50Times" percentComplete:100*(value/50.0)];
    [self submitAchievement:@"HeadOn.100Times" percentComplete:100*(value/100.0)];
    
    value = [[NSUserDefaults standardUserDefaults] integerForKey:Rookie];
    [self submitAchievement:@"HeadOn.Rookie" percentComplete:100*(value/10.0)];
    value = [[NSUserDefaults standardUserDefaults] integerForKey:Normal];
    [self submitAchievement:@"HeadOn.Normal" percentComplete:100*(value/10.0)];
    value = [[NSUserDefaults standardUserDefaults] integerForKey:Veteran];
    [self submitAchievement:@"HeadOn.Veteran" percentComplete:100*(value/5.0)];
    value = [[NSUserDefaults standardUserDefaults] integerForKey:Master];
    [self submitAchievement:@"HeadOn.Master" percentComplete:100*(value/1.0)];
    

    value = [[NSUserDefaults standardUserDefaults] integerForKey:FourBoard];
    [self submitAchievement:@"HeadOn.4x4" percentComplete:100*(value/10.0)];
    value = [[NSUserDefaults standardUserDefaults] integerForKey:FiveBoard];
    [self submitAchievement:@"HeadOn.5x5" percentComplete:100*(value/10.0)];
    value = [[NSUserDefaults standardUserDefaults] integerForKey:SixBoard];
    [self submitAchievement:@"HeadOn.6x6" percentComplete:100*(value/10.0)];
    
    value = [[NSUserDefaults standardUserDefaults] integerForKey:Solo];
    [self submitAchievement:@"HeadOn.Solo" percentComplete:100*(value/10.0)];
    value = [[NSUserDefaults standardUserDefaults] integerForKey:HeadToHead];
    [self submitAchievement:@"HeadOn.TwoPlayer" percentComplete:100*(value/10.0)];
    value = [[NSUserDefaults standardUserDefaults] integerForKey:MultiPlayer];
    [self submitAchievement:@"HeadOn.Multiplayer" percentComplete:100*(value/10.0)];
}

- (void) presentBanner: (NSString *) str {
    if ([str isEqualToString:@"HeadOn.FirstTimer"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"First game!" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.FiveTimes"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"Five in a Row" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.10Times"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"A Good Start" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.25Times"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"First Quarter" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.50Times"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"Half Way There" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.100Times"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"Finish Line" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.Rookie"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"A Walk in the Park" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.Normal"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"Average Joe" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.Veteran"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"Feel the Pain" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.Master"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"Unstoppable" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.4x4"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"Mini Board" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.5x5"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"Medium Board" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.6x6"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"Giant Board" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.Solo"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"Solo Mastery" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.TwoPlayer"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"Double Mastery" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.Multiplayer"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"Multi Mastery" completionHandler:nil];
    else if ([str isEqualToString:@"HeadOn.GrandMaster"])
        [GKNotificationBanner showBannerWithTitle:@"Achievement Unlocked" message:@"Master of the Universe" completionHandler:nil];
        
    
    completedAchievements += 1;
    [self submitAchievement:@"HeadOn.GrandMaster" percentComplete:(completedAchievements/16.0)];

}

- (void) initializeStatistics {
    NSLog(@"Initializing Statistics");
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:LocalTotal];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:Total];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:FourBoard];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:FiveBoard];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:SixBoard];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:Rookie];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:Normal];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:Veteran];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:Master];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:Solo];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:HeadToHead];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MultiPlayer];
    
    completedAchievements = 0;
}

- (void) addGameOnBoard: (int) boardSize againstComputer: (int) difficulty isOnlineGame: (BOOL) online p1Won: (BOOL) won{
    
    [self addOneTo:Total];
    
    if (difficulty > 0)
        [self addOneTo:LocalTotal];
    
    switch (boardSize) {
        case 4:
            [self addOneTo:FourBoard];
            break;
        case 5:
            [self addOneTo:FiveBoard];
            break;
        case 6:
            [self addOneTo:SixBoard];
            break;
        default:
            break;
    }
    
    if (won && difficulty > 0) {
        switch (difficulty) {
            case 2:
                [self addOneTo:Rookie];
                break;
            case 3:
                [self addOneTo:Normal];
                break;
            case 4:
                [self addOneTo:Veteran];
                break;
            case 5:
                [self addOneTo:Master];
                break;
            default:
                break;
        }
    }
    
    if (online)
        [self addOneTo:MultiPlayer];
    else if (difficulty > 0)
        [self addOneTo:Solo];
    else
        [self addOneTo:HeadToHead];
        
    [self checkAchievements];
}

- (void) addOneTo: (NSString *) str {
    int value = [[NSUserDefaults standardUserDefaults] integerForKey:str];
    value += 1;
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:str];
    NSLog(@"%@ : %i", str, value);
}

- (int) totalWins {
    int total = 0;
    total += [[NSUserDefaults standardUserDefaults] integerForKey:Rookie];
    total += [[NSUserDefaults standardUserDefaults] integerForKey:Normal];
    total += [[NSUserDefaults standardUserDefaults] integerForKey:Veteran];
    total += [[NSUserDefaults standardUserDefaults] integerForKey:Master];
    
    return total;
}

#pragma mark Property setters

-(void) setLastError:(NSError*)error {
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@", [[_lastError userInfo]
                                           description]);
    }
}

#pragma mark UIViewController stuff

-(UIViewController*) getRootViewController {
    return [UIApplication
            sharedApplication].keyWindow.rootViewController;
}

-(void)presentViewController:(UIViewController*)vc {
    UIViewController* rootVC = [self getRootViewController];
    [rootVC presentViewController:vc animated:YES
                       completion:nil];
}

@end
