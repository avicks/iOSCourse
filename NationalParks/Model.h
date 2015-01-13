//
//  Model.h
//  NationalParks
//
//  Created by alex on 10/15/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

-(NSInteger)numberOfParks;
-(NSDictionary*)getPark:(NSInteger)parkNumber;
-(NSInteger)photoCountOfPark:(NSInteger)parkNumber;
-(NSInteger)maxPhotoCount;
-(NSString*)titleForPark:(NSInteger)parkNumber;

@end
