//
//  Model.m
//  NationalParksII
//
//  Created by alex on 10/22/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import "Model.h"

@interface Model ()

@property (strong, nonatomic) NSMutableArray *parks;
@property (nonatomic, strong) NSCache *modelCache;

@end

@implementation Model

+(id)sharedInstance
{
   static id singleton;
   if(!singleton) {
      singleton = [[self alloc] init];
   }
   
   return singleton;
}

-(id)init
{
   self = [super init];
   if (self) {
      _parks = [self createParks];
      _modelCache = [[NSCache alloc] init];
   }
   
   return self;
}


-(NSMutableArray*)createParks
{
   NSBundle *mainBundle = [NSBundle mainBundle];
   NSString *path = [mainBundle pathForResource:@"Photos" ofType:@"plist"];
   NSArray *tempParks =[NSArray arrayWithContentsOfFile:path];
   
   // use a mutable array for editing of model
   NSMutableArray *parks = [NSMutableArray array];

   // go into nested arrays and dictionaries of our model and make sure they're all mutable
   for(NSDictionary *tempParkDictionary in tempParks) {

      NSString *parkName = [tempParkDictionary objectForKey:@"name"];
      NSArray *tempPhotoArray = [tempParkDictionary objectForKey:@"photos"];
      
      NSMutableArray *photoArray = [NSMutableArray array];

      for(NSDictionary *tempPhotoDictionary in tempPhotoArray) {
         NSString *imageName = [tempPhotoDictionary objectForKey:@"imageName"];
         NSString *caption = [tempPhotoDictionary objectForKey:@"caption"];
         NSString *photoPath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
         UIImage *photo = [UIImage imageWithContentsOfFile:photoPath];

         NSDictionary *photoDictionary =
            [@{@"imageName":photo, @"caption":caption, @"comments":@""} mutableCopy];
         [photoArray addObject:photoDictionary];
      }
      
      NSMutableDictionary *parkDictionary = [@{@"name":parkName,@"photos":photoArray} mutableCopy];
      [parks addObject:parkDictionary];
   }
   
   return parks;
}

-(NSString*)titleForPark:(NSInteger)parkNumber
{
   NSMutableDictionary *currentPark = [self getPark:parkNumber];
   NSString *title = [currentPark objectForKey:@"name"];
   
   return title;
}

-(NSString*)keyForPage:(NSInteger)parkNumber :(NSInteger)photoNumber
{
    return [NSString stringWithFormat:@"%ld%ld", (long)parkNumber, (long)photoNumber];
}

-(NSMutableDictionary*)dictionaryForPhoto:(NSInteger)parkNumber :(NSInteger)photoNumber
{
   NSString *key = [self keyForPage:parkNumber :photoNumber];
   NSMutableDictionary *dict = [self.modelCache objectForKey:key];
   if (!dict) {
      
      NSMutableDictionary *currentPark = [self getPark:parkNumber];
      NSMutableArray *photoArray = [currentPark objectForKey:@"photos"];
      NSMutableDictionary *currentPhoto = photoArray[photoNumber];
      UIImage *photo = [currentPhoto objectForKey:@"imageName"];
      NSString *caption = [currentPhoto objectForKey:@"caption"];
      NSString *comments = [currentPhoto objectForKey:@"comments"];

      dict = [@{@"caption":caption, @"photo":photo, @"comments":comments} mutableCopy];
      [self.modelCache setObject:dict forKey:key];
    }
   
    return dict;
}

-(NSString*)captionForPhoto:(NSInteger)parkNumber :(NSInteger)photoNumber
{
   NSMutableDictionary *dict = [self dictionaryForPhoto:parkNumber :photoNumber];
   NSString *caption = [dict objectForKey:@"caption"];
   return caption;
}

-(NSString*)commentsForPhoto:(NSInteger)parkNumber :(NSInteger)photoNumber
{
   NSMutableDictionary *dict = [self dictionaryForPhoto:parkNumber :photoNumber];
   NSString *comments = [dict objectForKey:@"comments"];
   return comments;
}

-(UIImage*)parkImage:(NSInteger)parkNumber :(NSInteger)photoNumber
{
   
   NSMutableDictionary *dict = [self dictionaryForPhoto:parkNumber :photoNumber];
   UIImage *photo = [dict objectForKey:@"photo"];

   return photo;
}

// Return the park dictionary of the given park number in the parks array
-(NSMutableDictionary*)getPark:(NSInteger)parkNumber
{
   NSMutableDictionary *park = [[NSMutableDictionary alloc] initWithDictionary:self.parks[parkNumber]];
   return park;
}

// return number of parks in our data
-(NSInteger)numberOfParks
{
   return [self.parks count];
}

// return number of images for an individual park
-(NSInteger)photoCountOfPark:(NSInteger)parkNumber
{
   NSMutableDictionary *park = [[NSMutableDictionary alloc] initWithDictionary:self.parks[parkNumber]];
   NSMutableArray *photos = [park objectForKey:@"photos"];
   return [photos count];
}


// find the park with the most number of photos to set our scrollView size
-(NSInteger)maxPhotoCount
{
   NSInteger maxCount = 0;
   NSInteger parkCount = [self numberOfParks];
   
   for(int parkNumber = 0; parkNumber < parkCount; parkNumber++) {
      NSInteger tempCount = [self photoCountOfPark:parkNumber];
      if(maxCount < tempCount) {
         maxCount = tempCount;
      }
   }
   
   return maxCount;
}
/*
-(NSArray*)sortArray
{

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

    NSArray *tempArray = [self.temporaryBuildingArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    return tempArray;
}
*/

#pragma mark - editing
-(void)removePark:(NSInteger)parkNumber :(NSInteger)photoNumber {
   NSMutableDictionary *currentPark = [self.parks objectAtIndex:parkNumber];
   NSMutableArray *photoArray = [currentPark objectForKey:@"photos"];
   [photoArray removeObjectAtIndex:photoNumber];
}

-(void)moveParkPhoto:(NSInteger)fromSection :(NSInteger)fromRow :(NSInteger)toSection :(NSInteger)toRow {

      NSMutableDictionary *currentPark = [self.parks objectAtIndex:fromSection];
      NSMutableArray *photoArray = [currentPark objectForKey:@"photos"];
      id item = [photoArray objectAtIndex:fromRow];
      [photoArray removeObjectAtIndex:fromRow];
      [photoArray insertObject:item atIndex:toRow];
}

-(void)addPark:(NSDictionary *)newPark
{
   [self.parks addObject:newPark];
}

-(void)addPhoto:(UIImage*)photo withTitle:(NSString*)title inSection:(NSInteger)section{
   NSDictionary *newPhotoDictionary =
      [@{@"imageName":photo, @"caption":title, @"comments":@""} mutableCopy];
   NSMutableDictionary *currentPark = [self.parks objectAtIndex:section];
   NSMutableArray *photoArray = [currentPark objectForKey:@"photos"];
   [photoArray addObject:newPhotoDictionary];
}

-(void)setCaption:(NSString*)caption forPhoto:(NSInteger)photoNumber ofPark:(NSInteger)parkNumber
{
   NSMutableDictionary *photoDictionary = [self dictionaryForPhoto:parkNumber :photoNumber];
   [photoDictionary setObject:caption forKey:@"caption"];

}

-(void)setComments:(NSString*)comments forPhoto:(NSInteger)photoNumber ofPark:(NSInteger)parkNumber
{
   NSMutableDictionary *photoDictionary = [self dictionaryForPhoto:parkNumber :photoNumber];
   [photoDictionary setObject:comments forKey:@"comments"];
}

-(void)sortParks
{
   NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

   [self.parks sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}


@end
