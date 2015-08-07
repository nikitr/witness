//
//  SharedDateFormatter.h
//  Witness
//
//  Created by Sean Vasquez on 7/27/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyManager: NSObject {
  NSDateFormatter *dateFormatter;
}

@property (nonatomic, retain) NSDateFormatter *dateFormatter;

+ (id)sharedManager;

@end