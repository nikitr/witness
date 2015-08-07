//
//  PhotoStackLayout.m
//  Maps
//
//  Created by Sean Vasquez on 7/19/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "PagingPhotoLayout.h"

@interface PagingPhotoLayout ()

@property (nonatomic) NSMutableDictionary *layoutInfo;

@end

@implementation PagingPhotoLayout

- (CGFloat)pageWidth {
  return self.itemSize.width + self.minimumLineSpacing;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
  CGFloat rawPageValue = self.collectionView.contentOffset.x / self.pageWidth;
  CGFloat currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
  CGFloat nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
  
  BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
  BOOL flicked = fabs(velocity.x) > [self flickVelocity];
  if (pannedLessThanAPage && flicked) {
    proposedContentOffset.x = nextPage * self.pageWidth;
  } else {
    proposedContentOffset.x = round(rawPageValue) * self.pageWidth;
  }
  
  return proposedContentOffset;
}

- (CGFloat)flickVelocity {
  return 0.3;
}

@end