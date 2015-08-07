//--------------------------------------------------------------------------------------------------
//  MaedaWheelsView.h created by erik on Sat 24-Mar-2001
//  @(#)$Id: MaedaWheelsView.h,v 1.3 2001/05/06 02:19:18 erik Exp $
//
//  This file is part of the MaedaWheels screen saver. It free software; you can 
//  redistribute and/or modify it under the terms of the GNU General Public License, 
//  version 2 as published by the Free Software Foundation.
//--------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaver.h>


@interface MaedaWheelsView : ScreenSaverView 
{
    float		*disc1Rotations;
    float		*disc2Rotations;

    float		disc1Speed;
    float		disc2Speed;

    int			wheelArraySize;
    float		relativeDisplaySize;
    NSColor		*canvasColor;
    NSColor		*disc1Color;
    NSColor		*disc2Color;
    NSColor		*innerColor;
}

- (void)reloadDefaults:(NSNotification *)notification;
- (void)resetRotations;
- (void)recalcSpeeds;

@end



extern NSString *MWDefaultsIdentifier;

extern NSString *MWWheelCountDefaultsKey;
extern NSString *MWCanvasSizeDefaultsKey;
extern NSString *MWCanvasColorDefaultsKey;
extern NSString *MWDisc1ColorDefaultsKey;
extern NSString *MWDisc2ColorDefaultsKey;
extern NSString *MWInnerColorDefaultsKey;

