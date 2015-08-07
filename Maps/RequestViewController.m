//
//  RequestViewController.m
//  Teleporter
//
//  Created by Nikita Rau on 7/9/15.
//
//

#import "RequestViewController.h"
#import "RequestTableCell.h"
#import "Request.h"

@interface RequestViewController () 

@end

@implementation RequestViewController
{
  NSMutableArray *requests;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [requests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *requestTableIdentifier = @"RequestTableCell";
  
  RequestTableCell *cell = (RequestTableCell *)[tableView dequeueReusableCellWithIdentifier:requestTableIdentifier];
  
  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RequestTableCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
  }
  
  cell.descriptionTextView.text = [requests objectAtIndex:indexPath.row];
//  cell.dateLabel.text = 
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 78;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  RequestTableCell *myCell = (RequestTableCell *)[tableView cellForRowAtIndexPath:indexPath];
  [self performSegueWithIdentifier:@"requestCam" sender:myCell];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
