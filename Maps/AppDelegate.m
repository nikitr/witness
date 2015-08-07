//
//  AppDelegate.m
//  Maps
//
//  Created by Sean Vasquez on 7/6/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "TeleporterMainViewController.h"
#import "LogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "MapSearchViewController.h"
@import CoreLocation;
@import UIKit;

@interface AppDelegate () <CLLocationManagerDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong, readwrite) CLLocationManager *backgroundLocationManager;


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  //Tab Bar Customization
  self.tbcontrol = (UITabBarController *)self.window.rootViewController;
  self.tbcontrol.delegate = self;
  
  UIImage *homeIcon = [UIImage imageNamed:@"Home"];
  UIImage *browseIcon = [UIImage imageNamed:@"Browse"];
  UIImage *inboxIcon = [UIImage imageNamed:@"Inbox"];
  UIImage *profileIcon = [UIImage imageNamed:@"Profile"];
  UIImage *centerIcon = [UIImage imageNamed:@"Center"];
  UITabBar *tabbar = self.tbcontrol.tabBar;
  UITabBarItem *item0 = [tabbar.items objectAtIndex:0];

  item0 = [item0 initWithTitle:nil image:homeIcon selectedImage:homeIcon];
  item0.imageInsets = UIEdgeInsetsMake(9, 0, -9, 0);
  UITabBarItem *item1 = [tabbar.items objectAtIndex:1];
  item1 = [item1 initWithTitle:nil image:browseIcon selectedImage:browseIcon];
  item1.imageInsets = UIEdgeInsetsMake(9, 0, -9, 0);
  UITabBarItem *item2 = [tabbar.items objectAtIndex:2];
  item2 = [item2 initWithTitle:nil image:centerIcon selectedImage:centerIcon];
  self.tbcontrol.tabBar.tintColor = [UIColor colorWithRed:135/255.0 green:110/255.0 blue:159/255.0 alpha:1.0];
  
  UITabBarItem *item3 = [tabbar.items objectAtIndex:3];
  item3 = [item3 initWithTitle:nil image:inboxIcon selectedImage:inboxIcon];
  item3.imageInsets = UIEdgeInsetsMake(9, 0, -9, 0);
  UITabBarItem *item4 = [tabbar.items objectAtIndex:4];
  item4 = [item4 initWithTitle:nil image:profileIcon selectedImage:profileIcon];
  item4.imageInsets = UIEdgeInsetsMake(9, 0, -9, 0);

  
  //UI settings
  [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
  
  NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [UIFont fontWithName:@"Heiti SC" size:15.0], NSForegroundColorAttributeName: [UIColor whiteColor]};
  [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
  
  NSShadow* shadow = [NSShadow new];
  shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
  shadow.shadowColor = [UIColor clearColor];
  [[UINavigationBar appearance] setTitleTextAttributes:
   @{NSForegroundColorAttributeName: [UIColor whiteColor],
     NSFontAttributeName: [UIFont fontWithName:@"Heiti SC" size:17.0f],
     NSShadowAttributeName: shadow}];
  [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
   setDefaultTextAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"Heiti SC" size:13],}];
  //Parse setup
  [Parse enableLocalDatastore];
  [Parse setApplicationId:@"l4uNwHgEKesjFU2g5NAfFGb5m0qkG4K77Pl066hi"
                clientKey:@"HpHiU1C5ySDUuqYPiV5S9yXCkeLlrP7uPBBaBCox"];
  // [Optional] Track statistics around application opens.
  [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
  [FBSDKLoginButton class];
  ///[PFUser logOut];
  if ([PFUser currentUser]) {
    NSLog(@"returningUser: %@", [PFUser currentUser].username);
  } else {
    NSLog(@"newUser");
    PFUser *user = [PFUser user];
    NSString *userDevice = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    user.username =  userDevice;
    user.password = @"defaultPassword";
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      if (!error) {
        NSLog(@"userCreated");
      } else {
        NSString *errorString = [error userInfo][@"error"];
        NSLog(@"%@", errorString);
      }
    }];
  }
  
  //The setup for receiving location updates when significant changes occur
  [self updateSessionCurrentLocation];
  [self setUpLocationManager];
  
  //Registering the notification types
  UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
  UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                           categories:nil];
  [application registerUserNotificationSettings:settings];
  [application registerForRemoteNotifications];
  
  return [[FBSDKApplicationDelegate sharedInstance] application:application
                                  didFinishLaunchingWithOptions:launchOptions];;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
  if ([viewController.title  isEqual: @"Placeholder"]) {
    MapSearchViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MapsVC"];
    [viewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self.tbcontrol presentViewController:viewController animated:YES completion:NULL];
    return NO;
  }
  return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                        openURL:url
                                              sourceApplication:sourceApplication
                                                     annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Notification Helpers

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  // Store the deviceToken in the current installation and save it to Parse.
  PFInstallation *currentInstallation = [PFInstallation currentInstallation];
  [currentInstallation setDeviceTokenFromData:deviceToken];
  currentInstallation.channels = @[ @"global" ];
  [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  [PFPush handlePush:userInfo];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  CLLocation *latestLocation = [locations lastObject];
  PFGeoPoint *latestGeoPoint = [PFGeoPoint geoPointWithLocation:latestLocation];
  [self updateCurrentSessionLocationWithGeoPoint:latestGeoPoint];
  //NSLog(@"new GeoPoint!");
}


#pragma mark - Location Helpers

- (void)setUpLocationManager {
  self.backgroundLocationManager = [[CLLocationManager alloc] init];
  self.backgroundLocationManager.delegate = self;
  [self.backgroundLocationManager startMonitoringSignificantLocationChanges];
  //NSLog(@"Now we are looking out for significant location changes");
}

- (void)updateCurrentSessionLocationWithGeoPoint:(PFGeoPoint *)geoPoint {
  [PFSession getCurrentSessionInBackgroundWithBlock:^(PFSession *session, NSError *error) {
    if (session && !error) {
      session[@"currentLocation"] = geoPoint;
      session[@"currentLocationUpdatedAt"] = [NSDate date];
      //NSLog(@"change to location %@ at %@", session[@"currentLocation"], session[@"currentLocationUpdatedAt"]);
      [session saveInBackground];
    }
  }];
}

- (void)updateSessionCurrentLocation {
  [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
    if (!error) {
      [self updateCurrentSessionLocationWithGeoPoint:geoPoint];
    }
  }];
}

@end
