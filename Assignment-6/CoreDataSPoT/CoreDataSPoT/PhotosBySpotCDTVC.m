//
//  PhotosBySpotCDTVC.m
//  CoreDataSPoT
//
//  Created by 孙 昱 on 13-12-19.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import "PhotosBySpotCDTVC.h"

#import "Photo.h"

@interface PhotosBySpotCDTVC ()

@end

@implementation PhotosBySpotCDTVC

- (void)setSpot:(Spot *)spot
{
    _spot = spot;
    self.title = spot.name;
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    if (self.spot.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"takenAt = %@", self.spot];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.spot.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - UITableViewDataSource

//

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIImageView *thumbnailImage = (UIImageView *)[cell viewWithTag:0];
    if (photo.thumbnailData) {
        thumbnailImage.image = [[UIImage alloc] initWithData:photo.thumbnailData];
    } else {
        // clear previous image
        thumbnailImage.image = nil;
        
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(imageFetchQ, ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;    // bad
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]];
            if (imageData) {
                photo.thumbnailData = imageData;
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    thumbnailImage.image = image;
                }
            });
        });
    }
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    titleLabel.text = photo.title;
    
    UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:2];
    subtitleLabel.text = photo.subtitle;
    

    
    return cell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setImageURL:"]) {
            Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                NSURL *url = [NSURL URLWithString:photo.imageURL];
                [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                [segue.destinationViewController setTitle:photo.title];
                
                // records the date when this photo is viewed by user
                photo.lastViewed = [NSDate date];
            }
        }
    }
}


@end
