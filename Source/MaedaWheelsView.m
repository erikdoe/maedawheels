//--------------------------------------------------------------------------------------------------
//  MaedaWheelsView.m created by erik on Sat 24-Mar-2001
//  @(#)$Id: MaedaWheelsView.m,v 1.4 2001/05/06 22:49:23 erik Exp $
//
//  This file is part of the MaedaWheels screen saver. It free software; you can 
//  redistribute and/or modify it under the terms of the GNU General Public License, 
//  version 2 as published by the Free Software Foundation.
//--------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "MaedaWheelsView.h"


//--------------------------------------------------------------------------------------------------
//	USER DEFAULTS KEYS
//--------------------------------------------------------------------------------------------------

NSString *MWDefaultsIdentifier = nil;

NSString *MWWheelCountDefaultsKey = @"WheelCount";
NSString *MWCanvasSizeDefaultsKey = @"CanvasSize";
NSString *MWCanvasColorDefaultsKey = @"CanvasColor";
NSString *MWDisc1ColorDefaultsKey = @"Disc1Color";
NSString *MWDisc2ColorDefaultsKey = @"Disc2Color";
NSString *MWInnerColorDefaultsKey = @"InnerColor";


//--------------------------------------------------------------------------------------------------
//	PARAMETERS THAT DIDN'T MAKE IT INTO THE USER DEFAULTS (YET)
//--------------------------------------------------------------------------------------------------

// whether or not to keep view's aspect ratio
#define WHEELS_ARE_CIRCLES YES

// wheel radius relative to wheel spacing
#define WHEEL_RADIUS 0.45

// variance in speed depending on mouse position
#define SPEED_RANGE 20

// initial rotational difference between centre and corners in degrees
#define HEADSTART_DISC1  90 // 90    
#define HEADSTART_DISC2  0

// relative speed between centre and corners
#define CORNERSPEED_DISC1  1.0    
#define CORNERSPEED_DISC2  1.0 // 0.5


//==================================================================================================
    @implementation MaedaWheelsView
//==================================================================================================

//--------------------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//--------------------------------------------------------------------------------------------------

+ (void)initialize
{
    NSUserDefaults 		*defaults;
    NSMutableDictionary	*factorySettings;
    NSData				*colorData;
    
    MWDefaultsIdentifier = [[NSBundle bundleForClass:self] bundleIdentifier];
    defaults = [ScreenSaverDefaults defaultsForModuleWithName:MWDefaultsIdentifier];
    factorySettings = [NSMutableDictionary dictionary];

    [factorySettings setObject:[NSNumber numberWithInt:9] forKey:MWWheelCountDefaultsKey];
    [factorySettings setObject:[NSNumber numberWithInt:5] forKey:MWCanvasSizeDefaultsKey];
    colorData = [NSArchiver archivedDataWithRootObject:[NSColor darkGrayColor]];
    [factorySettings setObject:colorData forKey:MWCanvasColorDefaultsKey];
    colorData = [NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
    [factorySettings setObject:colorData forKey:MWDisc1ColorDefaultsKey];
    colorData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.667 green:0.2 blue:0.2 alpha:1]];
    [factorySettings setObject:colorData forKey:MWDisc2ColorDefaultsKey];
    colorData = [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]];
    [factorySettings setObject:colorData forKey:MWInnerColorDefaultsKey];
    
    [defaults registerDefaults:factorySettings];
}


//--------------------------------------------------------------------------------------------------
//  INIT & DEALLOC
//--------------------------------------------------------------------------------------------------

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    NSUserDefaults	*saverDefaults;

    self = [super initWithFrame:frame isPreview:isPreview];

    [self allocateGState];
    disc1Rotations = NSZoneMalloc(nil, 1);
    disc2Rotations = NSZoneMalloc(nil, 1);
    disc1Speed = disc2Speed = 0;
    
    saverDefaults = [ScreenSaverDefaults defaultsForModuleWithName:MWDefaultsIdentifier];
    [self reloadDefaults:[NSNotification notificationWithName:NSUserDefaultsDidChangeNotification object:saverDefaults]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDefaults:) name:NSUserDefaultsDidChangeNotification object:saverDefaults];
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSZoneFree(nil, disc1Rotations);
    NSZoneFree(nil, disc2Rotations);
}


//--------------------------------------------------------------------------------------------------
//	SETUP 
//--------------------------------------------------------------------------------------------------

- (void)resetRotations
{
    float		distance, headstart;
    int	  		xi, yi;

    NSZoneFree(nil, disc1Rotations);
    disc1Rotations = NSZoneMalloc(nil, sizeof(float) * wheelArraySize * wheelArraySize);
    NSZoneFree(nil, disc2Rotations);
    disc2Rotations = NSZoneMalloc(nil, sizeof(float) * wheelArraySize * wheelArraySize);

    for(xi = 0; xi < wheelArraySize; xi++)
        for(yi = 0; yi < wheelArraySize; yi++)
            {
            distance = (abs(xi - wheelArraySize/2) + (float)abs(yi - wheelArraySize/2));
            headstart = (distance / (float)wheelArraySize) * HEADSTART_DISC1;
            disc1Rotations[yi * wheelArraySize + xi] = headstart;
            headstart = (distance / (float)wheelArraySize) * HEADSTART_DISC2;
            disc2Rotations[yi * wheelArraySize + xi] = headstart;
            }
}


- (void)recalcSpeeds
{
    NSRect	screenRect;
    NSPoint	mouseLocation;

    screenRect = [[NSScreen mainScreen] frame];
    mouseLocation = [NSEvent mouseLocation];
    
    disc1Speed = mouseLocation.x / screenRect.size.width * SPEED_RANGE - SPEED_RANGE/2;
    disc2Speed = mouseLocation.y / screenRect.size.height * SPEED_RANGE - SPEED_RANGE/2;
}


- (void)reloadDefaults:(NSNotification *)notification
{
    NSUserDefaults	*defaults;
    NSData			*colorData;
       
    //NSLog(@"[%@ %@] notification = %@", NSStringFromClass(isa), NSStringFromSelector(_cmd), notification);
    defaults = [ScreenSaverDefaults defaultsForModuleWithName:MWDefaultsIdentifier];

    wheelArraySize = [defaults integerForKey:MWWheelCountDefaultsKey];
    [self resetRotations];
    relativeDisplaySize = (float)[defaults integerForKey:MWCanvasSizeDefaultsKey] / 8.0;
        
    colorData = [defaults objectForKey:MWCanvasColorDefaultsKey];
    NSAssert(colorData != nil, @"could not read canvas colour");
    canvasColor = [NSUnarchiver unarchiveObjectWithData:colorData];    

    colorData = [defaults objectForKey:MWDisc1ColorDefaultsKey];
    NSAssert(colorData != nil, @"could not read disc 1 colour");
    disc1Color = [NSUnarchiver unarchiveObjectWithData:colorData];    

    colorData = [defaults objectForKey:MWDisc2ColorDefaultsKey];
    NSAssert(colorData != nil, @"could not read disc 2 colour");
    disc2Color = [NSUnarchiver unarchiveObjectWithData:colorData];    

    colorData = [defaults objectForKey:MWInnerColorDefaultsKey];
    NSAssert(colorData != nil, @"could not read inner colour");
    innerColor = [NSUnarchiver unarchiveObjectWithData:colorData];    
        
    [self setNeedsDisplay:YES];
}


//--------------------------------------------------------------------------------------------------
//  STANDARD VIEW OVERRIDES
//--------------------------------------------------------------------------------------------------

- (void)drawRect:(NSRect)rect
{
    [canvasColor set];
    NSRectFill(rect);
    [self drawFrame];
}


- (void)mouseEntered:(NSEvent *)theEvent
{
}


- (void)mouseExited:(NSEvent *)theEvent
{
}


- (void)mouseMoved:(NSEvent *)theEvent
{
    [self recalcSpeeds];
}


//--------------------------------------------------------------------------------------------------
//	SCREEN SAVER INTERFACE
//--------------------------------------------------------------------------------------------------

- (NSTimeInterval)animationTimeInterval
{
    return 1.0/30.0;
}


- (void)startAnimation
{
    [super startAnimation];
    [self recalcSpeeds];
}


- (void)animateOneFrame
{
    [self setNeedsDisplay:YES];
}


//--------------------------------------------------------------------------------------------------
//    ANIMATION
//--------------------------------------------------------------------------------------------------

- (void)drawFrame
{
    NSBezierPath    *circlePath, *discPath;
    int                xi, yi;
    NSRect            bounds;
    float            llx, lly, wrllx, wrlly, dcx, dcy, dr, wrs, displaySize;
    float            d1r, d2r, distance, slowdown;
    float             a1, a2, a3, a4;
    
    [[self window] disableFlushWindow];
    
    bounds = [self bounds];
    displaySize = MIN(bounds.size.width, bounds.size.height) * relativeDisplaySize;
    llx = (bounds.size.width - displaySize) / 2 + bounds.origin.x;
    lly = (bounds.size.height - displaySize) / 2 + bounds.origin.y;
    wrs = displaySize / wheelArraySize;
    dr = wrs * WHEEL_RADIUS;
    
    for(xi = 0; xi < wheelArraySize; xi++)
        for(yi = 0; yi < wheelArraySize; yi++)
        {
            d1r = disc1Rotations[(yi * wheelArraySize) + xi];
            d2r = disc2Rotations[(yi * wheelArraySize) + xi];
            
            distance = (abs(xi - wheelArraySize/2) + (float)abs(yi - wheelArraySize/2));
            slowdown = (distance / wheelArraySize) * (1.0 - CORNERSPEED_DISC1);
            d1r = fmod(d1r + disc1Speed * (1.0 - slowdown), 360.0);
            slowdown = (distance / wheelArraySize) * (1.0 - CORNERSPEED_DISC2);
            d2r = fmod(d2r + disc2Speed * (1.0 - slowdown), 360.0);
            
            disc1Rotations[(yi * wheelArraySize) + xi] = d1r;
            disc2Rotations[(yi * wheelArraySize) + xi] = d2r;
            
            wrllx = llx + xi * wrs;
            wrlly = lly + yi * wrs;
            dcx = wrllx + wrs/2;
            dcy = wrlly + wrs/2;
            
            circlePath = [NSBezierPath bezierPath];
            [circlePath appendBezierPathWithOvalInRect:NSMakeRect(wrllx + (wrs - 2*dr)/2, wrlly  + (wrs - 2*dr)/2, 2*dr, 2*dr)];
            [circlePath closePath];
            [circlePath setLineWidth:[self isPreview] ? 0.5 : 1.5];
            [innerColor set];
            [circlePath fill];
            
            a1 = d2r;  a2 = a1 + 90;  a3 = a2 + 180;  a4 = a3 - 90;
            discPath = [NSBezierPath bezierPath];
            [discPath moveToPoint:NSMakePoint(dcx + cos(a1*M_PI/180) * dr, dcy + sin(a1*M_PI/180) * dr)];
            [discPath appendBezierPathWithArcWithCenter:NSMakePoint(dcx, dcy) radius:dr startAngle:a1 endAngle:a2];
            [discPath lineToPoint:NSMakePoint(dcx, dcy)];
            [discPath closePath];
            [disc2Color set];
            [discPath fill];
            discPath = [NSBezierPath bezierPath];
            [discPath moveToPoint:NSMakePoint(dcx + cos(a4*M_PI/180) * dr, dcy + sin(a4*M_PI/180) * dr)];
            [discPath appendBezierPathWithArcWithCenter:NSMakePoint(dcx, dcy) radius:dr startAngle:a4 endAngle:a3];
            [discPath lineToPoint:NSMakePoint(dcx, dcy)];
            [discPath closePath];
            [disc2Color set];
            [discPath fill];
            
            a1 = d1r;  a2 = a1 + 90;  a3 = a2 + 180;  a4 = a3 - 90;
            discPath = [NSBezierPath bezierPath];
            [discPath moveToPoint:NSMakePoint(dcx + cos(a1*M_PI/180) * dr, dcy + sin(a1*M_PI/180) * dr)];
            [discPath appendBezierPathWithArcWithCenter:NSMakePoint(dcx, dcy) radius:dr startAngle:a1 endAngle:a2];
            [discPath lineToPoint:NSMakePoint(dcx, dcy)];
            [discPath closePath];
            [disc1Color set];
            [discPath fill];
            discPath = [NSBezierPath bezierPath];
            [discPath moveToPoint:NSMakePoint(dcx + cos(a4*M_PI/180) * dr, dcy + sin(a4*M_PI/180) * dr)];
            [discPath appendBezierPathWithArcWithCenter:NSMakePoint(dcx, dcy) radius:dr startAngle:a4 endAngle:a3];
            [discPath lineToPoint:NSMakePoint(dcx, dcy)];
            [discPath closePath];
            [disc1Color set];
            [discPath fill];
            
            [disc1Color set];
            [circlePath stroke];
        }
}


//==================================================================================================
    @end
//==================================================================================================
