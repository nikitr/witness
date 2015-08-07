//
//  PhotoDataSource.m
//  Maps
//
//  Created by Sean Vasquez on 7/13/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "PhotoDataSource.h"
#import "PhotoCell.h"


@implementation PhotoDataSource

- (instancetype)initWithPhotos{
  self = [super init];
  if (self) {
    self.photos = [[NSMutableArray alloc] init];
    for (int i = 0; i < 50; i++) {
      
      UIImage *black = [UIImage imageNamed:@"smiley.png"];
      [self.photos addObject:black];
    }
  }
  return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.photos.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  PhotoCell *cell =
  [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell"
                                            forIndexPath:indexPath];
  UIImage *photo = self.photos[indexPath.row];
  cell.backgroundColor=[UIColor redColor];
  [cell updateWithImage:photo];
  return cell;
}
@end
