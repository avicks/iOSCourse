//
//  CollectionViewController.m
//  NationalParksII
//
//  Created by alex on 10/26/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import "MyCollectionReusableView.h"
#import "DetailViewController.h"
#import "Model.h"


@interface CollectionViewController ()

@property (nonatomic, strong) Model *model;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) UIImageView *zoomedImageView;
@property (nonatomic, strong) NSIndexPath *zoomedIndexPath;
@property (nonatomic, strong) DetailViewController *detailViewController;

@end

@implementation CollectionViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   if (self) {
      _model = [Model sharedInstance];
   }
   return self;
}

#pragma mark - Collection View Data Source
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
   return self.model.numberOfParks;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   return [self.model photoCountOfPark:section];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *cellIdentifier = @"CollectionCell";
   CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
   
   cell.parkImageView.image = [self.model parkImage:indexPath.section :indexPath.row];

   return cell;
}

-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
   UICollectionReusableView *reusableView = nil;
   
   if (kind == UICollectionElementKindSectionHeader) {
        MyCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeaderView" forIndexPath:indexPath];
        NSString *title = [self.model titleForPark:indexPath.section];
        headerView.sectionHeader.text = title;

        reusableView = headerView;
    }
   
   return reusableView;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if([segue.identifier isEqualToString:@"collectionCellSegue"]){
      DetailViewController *detailViewController = segue.destinationViewController;
      NSArray *items =  [self.collectionView indexPathsForSelectedItems];
      NSIndexPath *indexPath = items[0];
      NSInteger parkNumber = indexPath.section;
      NSInteger photoNumber = indexPath.row;
      
      UIImage *parkImage = [self.model parkImage:indexPath.section :indexPath.row];
      NSString *parkName = [self.model titleForPark:indexPath.section];
      NSString *parkImageCaption = [self.model captionForPhoto:indexPath.section :indexPath.row];
      
      detailViewController.parkNumber = parkNumber;
      detailViewController.photoNumber = photoNumber;
      detailViewController.parkTitle = parkName;
      detailViewController.detailImage = parkImage;
      detailViewController.imageLabel = parkImageCaption;
   }
}


- (void)viewDidLoad
{
   [super viewDidLoad];
   self.title = @"Parks";
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10.0, 5.0, 10.0, 5.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
