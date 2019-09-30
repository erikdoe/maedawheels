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
    [canvasColorWell setColor:[NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:NULL]];

    colorData = [defaults objectForKey:MWDisc2ColorDefaultsKey];
    [disc2ColorWell setColor:[NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:NULL]];

    colorData = [defaults objectForKey:MWInnerColorDefaultsKey];
    [innerColorWell setColor:[NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:NULL]];
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
    
    colorData = [NSKeyedArchiver archivedDataWithRootObject:[canvasColorWell color] requiringSecureCoding:NO error:NULL];
    [defaults setObject:colorData forKey:MWCanvasColorDefaultsKey];

    colorData = [NSKeyedArchiver archivedDataWithRootObject:[disc2ColorWell color] requiringSecureCoding:NO error:NULL];
    [defaults setObject:colorData forKey:MWDisc2ColorDefaultsKey];

    colorData = [NSKeyedArchiver archivedDataWithRootObject:[innerColorWell color] requiringSecureCoding:NO error:NULL];
    [defaults setObject:colorData forKey:MWInnerColorDefaultsKey];

    // Manual synchornisation seems to be required now.
    [defaults synchronize];

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
