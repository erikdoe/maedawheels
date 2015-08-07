//--------------------------------------------------------------------------------------------------
//  MWConfigureSheetController.h created by erik on Sat 24-Mar-2001
//  @(#)$Id: MWConfigureSheetController.h,v 1.2 2001/04/25 20:11:41 erik Exp $
//
//  This file is part of the MaedaWheels screen saver. It free software; you can 
//  redistribute and/or modify it under the terms of the GNU General Public License, 
//  version 2 as published by the Free Software Foundation.
//--------------------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>


@interface MWConfigureSheetController : NSWindowController 
{
    NSUserDefaults			*defaults;
    
    IBOutlet NSSlider		*wheelCountSlider;
    IBOutlet NSTextField	*wheelCountField;
    IBOutlet NSSlider		*canvasSizeSlider;
    IBOutlet NSTextField	*canvasSizeField;
    IBOutlet NSColorWell	*canvasColorWell;
    IBOutlet NSColorWell	*disc2ColorWell;
    IBOutlet NSColorWell	*innerColorWell;
}

+ (id)sharedInstance;

- (IBAction)updateUserDefaults:(id)sender;
- (IBAction)closeConfigureSheet:(id)sender;

@end
