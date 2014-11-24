//
//  CollectionViewController.m
//  PagedCollectionView
//
//  Created by Daniel Farrelly on 23/11/2014.
//  Copyright (c) 2014 Daniel Farrelly. All rights reserved.
//

#import "CollectionViewController.h"

@interface CollectionViewController ()

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    // Take note that basic setup is performed in the storyboard. There is nothing particularly special about it
    // other than the fact that paging is NOT enabled. This is because:
    //     a) It would jack up our adjusted page widths.
    //     b) It would mean that `scrollViewWillEndDragging:withVelocity:targetContentOffset:` is not called.
    // So basically, this solution uses content insets, and then custom paging code that takes the adjusted size
    // into account.

    // Here we set up the layout to have 10pt between cells, and 10pt preceeding the first column of cells.
    // The section inset makes it easier to calculate the page positions, because it makes all the pages the same.

    [(UICollectionViewFlowLayout *)self.collectionViewLayout setSectionInset:UIEdgeInsetsMake( 0, 10.0f, 0, 0 )];
    [(UICollectionViewFlowLayout *)self.collectionViewLayout setMinimumLineSpacing:10.0f];
    [(UICollectionViewFlowLayout *)self.collectionViewLayout setMinimumInteritemSpacing:10.0f];

    // Inset the content on the right and left sides so that we get a 10pt "peek" at the next page, and make room
    // for the interitem spacing (also 10pt). Note that the left inset is adjust to account for the section inset
    // provided above.

    self.collectionView.contentInset = UIEdgeInsetsMake( 40.0f, 10.0f, 20.0f, 20.0f );

    // This is important. The normal deceleration rate would mean that swiping slowly would make the page snapping
    // animate slowly, which isn't how the default paging works. Fast deceleration makes the pages snap just like
    // they would in if you turned on paging.

    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
}

- (void)viewWillLayoutSubviews {

    // Get the size of the page, adjusting for the content insets.
    CGRect insetFrame = UIEdgeInsetsInsetRect( self.collectionView.frame, self.collectionView.contentInset );

    // Adjust for our interitem spacing.
    CGFloat pixelWidth = insetFrame.size.width - ( 10 * 4 );

    // Divide by the number of cells we desire (note the conversion to and from pixels).
    CGFloat cellWidth = ( ( pixelWidth * UIScreen.mainScreen.scale ) / 4 ) / UIScreen.mainScreen.scale;

    // Apply to the layout.
    [(UICollectionViewFlowLayout *)self.collectionViewLayout setItemSize:CGSizeMake( cellWidth, cellWidth )];

}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 500;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    // Make a pattern so we can see what's going on.
    if( fmodf( indexPath.row, 4 ) == 0 ) {
        cell.backgroundColor = [UIColor darkGrayColor];
    }
    else {
        cell.backgroundColor = [UIColor lightGrayColor];
    }

    return cell;
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    // Get the size of the page, adjusting for the content insets.
    CGRect insetFrame = UIEdgeInsetsInsetRect( self.collectionView.frame, self.collectionView.contentInset );

    // Determine the page index to fall on based on scroll position.
    CGFloat pageIndex = self.collectionView.contentOffset.x / insetFrame.size.width;

    // Going forward, we round to the next page.
    if( velocity.x > 0 ) {
        pageIndex = ceilf( pageIndex );
    }

    // Round to the closest page if we have no velocity.
    else if( velocity.x == 0 ) {
        pageIndex = roundf( pageIndex );
    }

    // Round to the previous page (odds are, we're going backwards).
    else {
        pageIndex = floorf( pageIndex );
    }

    // This is likely our new offset
    CGFloat newOffset = ( pageIndex * insetFrame.size.width );
	
	// If we don't have enough for a full page at the end, snap to the end point.
	// This means the penultimate page will have some content crossover with the
	// last page, and mirrors the default paging behaviour.
	if( newOffset > self.collectionView.contentSize.width - insetFrame.size.width ) {
		newOffset = self.collectionView.contentSize.width - insetFrame.size.width;
	}

    // Set our target content offset.
    // We multiply the target page index by the page width, and adjust for the content inset.
    targetContentOffset->x = newOffset - self.collectionView.contentInset.left;
}

@end
