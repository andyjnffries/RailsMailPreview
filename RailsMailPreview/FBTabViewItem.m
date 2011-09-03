//
//  FBTabViewItem.m
//  RailsMailPreview
//
//  Created by Fernando Barajas on 9/1/11.
//  Copyright 2011 Fernando Barajas. All rights reserved.
//


#import "FBTabViewItem.h"
#import "FBTabViewBar.h"


@implementation FBTabViewItem
@synthesize active;
@synthesize itemIndex;

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    leftImage   = [[NSImage imageNamed:@"tabLeftCap.png"] retain];
    centerImage = [[NSImage imageNamed:@"tabCenter.png"] retain];
    rightImage  = [[NSImage imageNamed:@"tabRightCap.png"] retain];
    
    leftImageInActive   = [[NSImage imageNamed:@"tabLeftCapInActive.png"] retain];
    centerImageInActive = [[NSImage imageNamed:@"tabCenterCapInActive.png"] retain];
    rightImageInActive  = [[NSImage imageNamed:@"tabRightCapInActive.png"] retain];
    
    titleField  = [[NSTextField alloc] initWithFrame:NSMakeRect(15, 1, 
                                                                CGRectGetWidth(frame) - 32, 
                                                                CGRectGetHeight(frame) - 4)];
    [titleField setEditable:NO];
    [titleField setSelectable:NO];
    [titleField setBezeled:NO];
    [titleField setDrawsBackground:NO];
    [titleField setAutoresizingMask:NSViewMaxXMargin | NSViewWidthSizable];
    [titleField setAlignment:NSCenterTextAlignment];
    [titleField setFont:[NSFont boldSystemFontOfSize:12.0]];
    [[titleField cell] setBackgroundStyle:NSBackgroundStyleRaised];
    
    [self addSubview:titleField];
  }
  return self;
}

- (void)setTitle:(NSString *)aTitle
{
  [titleField setStringValue:aTitle];
}

- (NSString *)title
{
  return [titleField stringValue];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
  return YES;
}

- (BOOL)acceptsFirstResponder
{
  return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
  [(FBTabViewBar *)[self superview] setAllInActive];
  [self setActive:YES];
  [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect
{
  if ([self active]) {
    NSDrawThreePartImage([self bounds], leftImage, centerImage, rightImage, NO, NSCompositeSourceOver, 1, NO);
  } 
  else {
    if (itemIndex == 0) {
      NSDrawThreePartImage([self bounds], leftImageInActive, centerImageInActive, leftImage, NO, NSCompositeSourceOver, 1, NO);
    }
    else if (itemIndex == 1) {
      NSDrawThreePartImage([self bounds], rightImage, centerImageInActive, rightImageInActive, NO, NSCompositeSourceOver, 1, NO);
    }
  }
}


- (void)dealloc {
  [leftImageInActive release];
  [centerImageInActive release];
  [rightImageInActive release];
  
  [leftImage release];
  [centerImage release];
  [rightImage release];
  [titleField release];
  [super dealloc];
}

@end