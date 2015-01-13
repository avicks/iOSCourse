//
//  TableViewController.m
//  NationalParksII
//
//  Created by alex on 10/22/14.
//  Copyright (c) 2014 Alex Vickers. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"
#import "Model.h"
#import "DetailViewController.h"
#import "ScrollDetailViewController.h"
#import "AddParkViewController.h"
#import "AddTableViewCell.h"

#define kSectionHeaderHeight 40

@interface TableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (nonatomic, strong) Model *model;
@property NSMutableArray *sectionStateArray;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) UIImageView *zoomedImageView;
@property (nonatomic, strong) NSIndexPath *zoomedIndexPath;
@property (nonatomic, strong) DetailViewController *detailViewController;
@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, strong) UIImage *pickedImage;
@end

@implementation TableViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   if (self) {
      _model = [Model sharedInstance];
   }
   return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillBeShown:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGRect frame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize kbSize = frame.size;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    
}

-(void)keyboardWillHide:(NSNotification*)notification {
    self.tableView.contentInset = UIEdgeInsetsZero;
}


- (void)viewDidLoad
{
   [super viewDidLoad];
   self.title = @"Parks";

	// Do any additional setup after loading the view, typically from a nib.
   
   // make sure table view doesn't overlap tab bar or status bar
   self.navigationItem.rightBarButtonItem = self.editButtonItem;
   //self.navigationItem.leftBarButtonItem
   
   if(!_sectionStateArray) {
      _sectionStateArray    = [[NSMutableArray alloc] init];
      NSInteger sectionCount = self.model.numberOfParks;
      for(int i = 0; i < sectionCount; i++) {
         _sectionStateArray[i] = [NSNumber numberWithBool:YES];
      }
   }
}

-(void)awakeFromNib {
   if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      UINavigationController *navController = [self.splitViewController.viewControllers lastObject];
      
      self.detailViewController = (id)navController.topViewController;
      self.splitViewController.delegate = self.detailViewController;
   }
}

#pragma mark - table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return [self.sectionStateArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   NSInteger photoCount = [self.model photoCountOfPark:section];
   if(_sectionStateArray[section] == [NSNumber numberWithBool:YES]) {
      NSInteger count = self.editing ? photoCount + 1 : photoCount;
         return count;
   } else {
      return 0;
   }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSInteger photoCount = [self.model photoCountOfPark:indexPath.section];

    if (self.editing && indexPath.row == photoCount) {
        AddTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCellIdentifier" forIndexPath:indexPath];
        cell.photoCaptionTextField.text = @"";
        [cell.imagePickerButton addTarget:self action:@selector(selectPhotoPressed:) forControlEvents:UIControlEventTouchUpInside];

        return cell;
    }

   static NSString *cellIdentifier = @"CellIdentifier";
   
   TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

   cell.photoCaption.text = [self.model captionForPhoto:indexPath.section :indexPath.row];
   cell.photoThumbnail.image = [self.model parkImage:indexPath.section :indexPath.row];

   return cell;
}

// Make sure first header shows up on iPhone view
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kSectionHeaderHeight)];
   headerView.tag = section;
   headerView.backgroundColor = [UIColor brownColor];
   UILabel *headerString =
      [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kSectionHeaderHeight)];
   
   headerString.text = [self.model titleForPark:section];
   headerString.textAlignment = NSTextAlignmentCenter;
   headerString.textColor = [UIColor whiteColor];
   headerString.font = [UIFont boldSystemFontOfSize:20];
   [headerView addSubview:headerString];
   
    // set up the tap gesture recognizer
    UITapGestureRecognizer *tapGesture =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
    [headerView addGestureRecognizer:tapGesture];
   
   return headerView;
}

-(void)toggleOpen:(UITapGestureRecognizer *)gestureRecognizer
{
   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
   if(indexPath.row == 0) {
      BOOL isCollapsed = [[_sectionStateArray objectAtIndex:indexPath.section] boolValue];
      isCollapsed = !isCollapsed;
      [_sectionStateArray replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithBool:isCollapsed]];
   
      NSRange range   = NSMakeRange(indexPath.section, 1);
      NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
      [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
   }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      TableViewCell *cell = (TableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
      NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
      NSString *parkName = [self.model titleForPark:indexPath.section];
      
      [self.detailViewController.scrollViewButton setBackgroundImage:cell.photoThumbnail.image forState:UIControlStateNormal];
      self.detailViewController.scrollViewButton.imageView.image = cell.photoThumbnail.image;
      self.detailViewController.detailParkImageCaption.text = cell.photoCaption.text;
      self.detailViewController.detailParkImageCaption.hidden = NO;
      self.detailViewController.title = parkName;

   }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

      if([segue.identifier isEqualToString:@"tableCellSegue"]){
         NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
         NSInteger parkNumber = indexPath.section;
         NSInteger photoNumber = indexPath.row;

         DetailViewController *detailViewController = segue.destinationViewController;

         detailViewController.parkTitle = [self.model titleForPark:parkNumber];;
         detailViewController.parkNumber = parkNumber;
         detailViewController.photoNumber = photoNumber;
         
         detailViewController.detailImage = [self.model parkImage:parkNumber :photoNumber];;
         
         detailViewController.captionText =
            [self.model captionForPhoto:parkNumber :photoNumber];
         detailViewController.commentsText =
            [self.model commentsForPhoto:parkNumber :photoNumber];
         
         detailViewController.completionBlock = ^(NSDictionary *dictionary){
           NSString *caption = dictionary[@"caption"];
           NSString *comments = dictionary[@"comments"];
           [self.model setCaption:caption forPhoto:photoNumber ofPark:parkNumber];
           [self.model setComments:comments forPhoto:photoNumber ofPark:parkNumber];
           [self.tableView reloadData];
         };
         
      } else if([segue.identifier isEqualToString:@"AddParkSegue"]) {
         AddParkViewController *addParkViewController = segue.destinationViewController;
         
         addParkViewController.completionBlock = ^(id obj) {
            [self dismissViewControllerAnimated:YES completion:NULL];
            
            if(obj) {
               
               NSMutableArray *photos = [NSMutableArray array];
               NSDictionary *newPark = [@{@"name":obj, @"photos":photos} mutableCopy];

               [self.model addPark:newPark];
               [self.sectionStateArray addObject:[NSNumber numberWithBool:YES]];
               [self.model sortParks];
               [self.tableView reloadData];
            }
         };
      }
   }
}

#pragma mark - Cell editing
-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView reloadData];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger rowCount = [self.model photoCountOfPark:indexPath.section];
    if (self.editing && indexPath.row == rowCount) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.model removePark:indexPath.section :indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        AddTableViewCell *cell = (AddTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        NSString *name = cell.photoCaptionTextField.text;
        UIImage *newImage = _pickedImage;
       
       if(name.length == 0) {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a caption for the photo." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: @"Done", nil];
            [alertView show];
       } else if (_pickedImage == nil) {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select an image." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: @"Done", nil];
            [alertView show];
       } else {
            cell.photoCaptionTextField.text = @"";
            _pickedImage = nil;
            [self.model addPhoto:newImage withTitle:name inSection:indexPath.section];
            [tableView reloadData];
       }
   }
}

#pragma mark - New photo image selection
- (IBAction)selectPhotoPressed:(id)sender {
   
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.allowsEditing = YES;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    _pickedImage = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
   _pickedImage = nil;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - Cell moving
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
   [self.model
      moveParkPhoto:fromIndexPath.section :fromIndexPath.row :toIndexPath.section :toIndexPath.row];   
}

// Make sure a row is only able to be rearranged inside it's own section
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
   // get row count of section
   NSInteger photoCount = [self.model photoCountOfPark:sourceIndexPath.section];
   NSInteger row = 0;
   
   if(sourceIndexPath.section != proposedDestinationIndexPath.section) {
      
      // if the cell is moved outside of the section, send it back above the "add a photo" cell
      if(sourceIndexPath.section < proposedDestinationIndexPath.section) {
         row = photoCount - 1;
      }
      
      return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
   } else {
      // if cell is in it's own section, make sure it always appears above the "add a photo" cell
      if(proposedDestinationIndexPath.row == photoCount) {
         row = photoCount - 1;
         return [NSIndexPath indexPathForRow:row inSection:proposedDestinationIndexPath.section];
      }
      
      return proposedDestinationIndexPath;
   }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
   // Make sure the "add a photo" cell cannot be moved when editing
   NSInteger photoCount = [self.model photoCountOfPark:indexPath.section];
   if(indexPath.row == photoCount) {
      return NO;
   } else {
      return YES;
   }
}
@end
