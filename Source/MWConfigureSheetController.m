//--------------------------------------------------------------------------------------------------
//  MWConfigureSheetController.m created by erik on Sat 24-Mar-2001
//  @(#)$Id: MWConfigureSheetController.m,v 1.2 2001/04/25 20:11:41 erik Exp $
//
//  This file is part of the MaedaWheels screen saver. It free software; you can 
//  redistribute and/or modify it under the terms of the GNU General Public License, 
//  version 2 as published by the Free Software Foundation.
//--------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaver.h>
#import "MaedaWheelsView.h"
#import "MWConfigureSheetController.h"


//==================================================================================================
    @implementation MaedaWheelsView(ConfigureSheetAdditions)
//==================================================================================================

- (BOOL)hasConfigureSheet
{
    return YES;
}


- (NSWindow *)configureSheet
{
    return [[MWConfigureSheetController sharedInstance] window];
}


//==================================================================================================
    @end
//==================================================================================================



//==================================================================================================
    @implementation MWConfigureSheetController
//==================================================================================================

//--------------------------------------------------------------------------------------------------
//	INIT & DEALLOC
//--------------------------------------------------------------------------------------------------

+ (id)sharedInstance
{
    static MWConfigureSheetController *instance = nil;
    
    if(instance == nil)
        instance = [[MWConfigureSheetController alloc] init];
    
    return instance;
}

- (id)init
{
    self = [self initWithWindowNibName:@"ConfigureSheet"];
    defaults = [ScreenSaverDefaults defaultsForModuleWithName:MWDefaultsIdentifier];
    return self;
}




//--------------------------------------------------------------------------------------------------
//	SHOW DEFAULTS
//--------------------------------------------------------------------------------------------------

- (void)windowDidLoad
{
    NSData	*colorData;
    int		intValue;
    
    intValue = [defaults integerForKey:MWWheelCountDefaultsKey];
    [wheelCountSlider setIntValue:(intValue - 1) / 2];
    [wheelCountField setStringValue:[NSString stringWithFormat:@"(%dx%d)", intValue, intValue]];

    intValue = [defaults integerForKey:MWCanvasSizeDefaultsKey];
    [canvasSizeSlider setIntValue:intValue];
    [canvasSizeField setStringValue:[NSString stringWithFormat:@"(%.0f%%)", (float)intValue / 8.0 * 100]];

    colorData = [defaults objectForKey:MWCanvasColorDefaultsKey];
    [canvasColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorData]];

    colorData = [defaults objectForKey:MWDisc2ColorDefaultsKey];
    [disc2ColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorData]];

    colorData = [defaults objectForKey:MWInnerColorDefaultsKey];
    [innerColorWell setColor:[NSUnarchiver unarchiveObjectWithData:colorData]];
}


//--------------------------------------------------------------------------------------------------
//	UPDATE DEFAULTS
//--------------------------------------------------------------------------------------------------

- (IBAction)updateUserDefaults:(id)sender
{
    NSData	*colorData;
    int 	intValue;
    
    intValue = [wheelCountSlider intValue] * 2 + 1;
    [defaults setInteger:intValue forKey:MWWheelCountDefaultsKey];
    [wheelCountField setStringValue:[NSString stringWithFormat:@"(%dx%d)", intValue, intValue]];

    intValue = [canvasSizeSlider intValue];
    [defaults setInteger:intValue forKey:MWCanvasSizeDefaultsKey];
    [canvasSizeField setStringValue:[NSString stringWithFormat:@"(%.0f%%)", (float)intValue / 8.0 * 100]];
    
    colorData = [NSArchiver archivedDataWithRootObject:[canvasColorWell color]];
    [defaults setObject:colorData forKey:MWCanvasColorDefaultsKey];

    colorData = [NSArchiver archivedDataWithRootObject:[disc2ColorWell color]];
    [defaults setObject:colorData forKey:MWDisc2ColorDefaultsKey];

    colorData = [NSArchiver archivedDataWithRootObject:[innerColorWell color]];
    [defaults setObject:colorData forKey:MWInnerColorDefaultsKey];

    // This seems to be broken in the ScreenSaverDefaults, so we send it ourselves...
    [[NSNotificationCenter defaultCenter] postNotificationName:NSUserDefaultsDidChangeNotification object:defaults];
}


//--------------------------------------------------------------------------------------------------
//	CLOSE THE SHEET
//--------------------------------------------------------------------------------------------------

- (IBAction)closeConfigureSheet:(id)sender;
{
    [NSApp endSheet:[self window]];
}


//==================================================================================================
    @end
//==================================================================================================
