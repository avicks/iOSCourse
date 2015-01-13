//
//  Model.m
//  NationalParks
//
//  Created by alex on 10/15/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import "Model.h"

@interface Model ()

@property (strong, nonatomic) NSArray *parks;


@end

@implementation Model

-(id)init
{
   self = [super init];
   if (self) {
      _parks = [self createParks];
   }
   
   return self;
}


-(NSArray*)createParks {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:@"Photos" ofType:@"plist"];
    NSArray *parks = [NSArray arrayWithContentsOfFile:path];
    return parks;
   
}

-(NSString*)titleForPark:(NSInteger)parkNumber
{
   NSDictionary *currentPark = [self getPark:parkNumber];
   NSString *title = [currentPark objectForKey:@"name"];
   return title;
}

// Return the park dictionary of the given park number in the parks array
-(NSDictionary*)getPark:(NSInteger)parkNumber
{
   NSDictionary *park = [[NSDictionary alloc] initWithDictionary:self.parks[parkNumber]];
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
   NSDictionary *park = [[NSDictionary alloc] initWithDictionary:self.parks[parkNumber]];
   NSArray *photos = [park objectForKey:@"photos"];
   return [photos count];
}


// find the park with the most number of photos to set our scrollView size
-(NSInteger)maxPhotoCount
{
   NSInteger maxCount = 0;
   NSInteger parkCount = [self numberOfParks];
   //NSLog(@"%li",parkCount);
   
   for(int parkNumber = 0; parkNumber < parkCount; parkNumber++) {
      NSInteger tempCount = [self photoCountOfPark:parkNumber];
      //NSLog(@"%li",tempCount);
      if(maxCount < tempCount) {
         maxCount = tempCount;
         //NSLog(@"Max = %li",maxCount);
      }
   }
   
   //NSLog(@"Max = %li",maxCount);
   return maxCount;
}

@end
