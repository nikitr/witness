//
//  RequestViewController.h
//  Teleporter
//
//  Created by Nikita Rau on 7/9/15.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface RequestViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
