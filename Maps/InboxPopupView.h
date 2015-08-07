//
//  InboxPopupVIew.h
//  Witness
//
//  Created by Sean Vasquez on 7/25/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InboxPopupView;

@protocol PopupDelegate <NSObject>

@required
- (void)savePressed;
- (void)dontSavePressed;

@end

@interface InboxPopupView : UIView

@property (nonatomic) IBOutlet UILabel *saveDetails;
@property (nonatomic) IBOutlet UIButton *save;
@property (nonatomic) IBOutlet UIButton *dontSave;
@property (nonatomic, weak) id <PopupDelegate> popupDelegate;

@end
