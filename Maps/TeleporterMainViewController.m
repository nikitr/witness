//
//  TeleporterMainViewController.m
//

#import "TeleporterMainViewController.h"

#import <Parse/Parse.h>
#import "LogInViewController.h"
#import "RegistrationViewController.h"

@implementation TeleporterMainViewController

#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];

  // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)loadDestinationVC:(id)sender {
  [self performSegueWithIdentifier:@"loginSegue" sender:nil];
}


@end
