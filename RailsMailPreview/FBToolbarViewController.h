//
//  FBToolbarViewController.h
//  RailsMailPreview
//
//  Created by Fernando Barajas on 8/14/11.
//  Copyright 2011 Fernando Barajas. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FBToolbarViewController : NSViewController
{
  IBOutlet NSSegmentedControl * segmentControl;
}
- (IBAction)segmentedItemSelected:(id)sender;
@end
