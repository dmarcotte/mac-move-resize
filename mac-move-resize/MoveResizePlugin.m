#import "MoveResizePlugin.h"
#import "JRSwizzle.h"

@interface NSApplication (MoveResizePlugin)
- (void) moveResizeSendEvent:(NSEvent*) event;
@end

@implementation MoveResizePlugin

@synthesize resizeSection = _resizeSection;

/**
 * A special method called by SIMBL once the application has started and all classes are initialized.
 */
+ (void) load
{
    // construct our shared instance
    [MoveResizePlugin sharedInstance];
}

/**
 * @return the single static instance of the plugin object
 */
+ (MoveResizePlugin*) sharedInstance
{
    static MoveResizePlugin* plugin = nil;

    if (plugin == nil) {
        plugin = [[MoveResizePlugin alloc] init];

        NSError* error = nil;
        BOOL result = [NSApplication jr_swizzleMethod:@selector(sendEvent:) withMethod:@selector(moveResizeSendEvent:) error:&error];
        if (!result) {
            NSLog(@"Failed install event handlers.  Error: %@", error);
        }
    }

    return plugin;
}

@end

@implementation NSApplication (MoveResizePlugin)

- (void) moveResizeSendEvent:(NSEvent*) event {
    unsigned modifierKeys = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
    MoveResizePlugin* plugin = [MoveResizePlugin sharedInstance];

    BOOL eventHandled = false;

    // do move and resize actions when command and control are held down
    if (modifierKeys == (NSCommandKeyMask | NSControlKeyMask)) {

        eventHandled = true;
        NSWindow* wnd = [event window];

        switch ([event type]) {
            case NSLeftMouseDown:
                // ensure we bring the app into focus
                [NSApp activateIgnoringOtherApps:YES];
                break;
            case NSRightMouseDown: {
                // on right click, record which direction we should resize in on the drag
                struct ResizeSection resizeSection;

                NSPoint clickPoint = [event locationInWindow];

                NSSize wndSize = [wnd frame].size;

                if (clickPoint.x < wndSize.width/3) {
                    resizeSection.xResizeDirection = left;
                } else if (clickPoint.x > 2*wndSize.width/3) {
                    resizeSection.xResizeDirection = right;
                } else {
                    resizeSection.xResizeDirection = noX;
                }

                if (clickPoint.y < wndSize.height/3) {
                    resizeSection.yResizeDirection = bottom;
                } else  if (clickPoint.y > 2*wndSize.height/3) {
                    resizeSection.yResizeDirection = top;
                } else {
                    resizeSection.yResizeDirection = noY;
                }

                [plugin setResizeSection:resizeSection];

                break;
            }

            case NSLeftMouseDragged: {
                NSPoint origin = [wnd frame].origin;
                origin.x += [event deltaX];
                origin.y -= [event deltaY];
                [wnd setFrameOrigin:origin];

                // ensure the dragged window stays in front
                [event.window makeKeyAndOrderFront:self];

                break;
            }

            case NSRightMouseDragged: {
                struct ResizeSection resizeSection = [plugin resizeSection];

                if (wnd && ([wnd styleMask] & NSResizableWindowMask)) {

                    NSRect frame = [wnd frame];
                    NSSize minSize = [wnd minSize];

                    switch (resizeSection.xResizeDirection) {
                        case right:
                            frame.size.width += [event deltaX];
                            if (frame.size.width < minSize.width) {
                                frame.size.width = minSize.width;
                            }
                            break;
                        case left:
                            frame.size.width -= [event deltaX];
                            if (frame.size.width < minSize.width) {
                                frame.size.width = minSize.width;
                            } else {
                                frame.origin.x += [event deltaX];
                            }
                            break;
                        case noX:
                            // nothing to do
                            break;
                        default:
                            [NSException raise:@"Unknown xResizeSection" format:@"No case for %d", resizeSection.xResizeDirection];
                    }

                    switch (resizeSection.yResizeDirection) {
                        case top:
                            frame.size.height -= [event deltaY];
                            if (frame.size.height < minSize.height) {
                                frame.size.height = minSize.height;
                            }
                            break;
                        case bottom:
                            frame.size.height += [event deltaY];
                            if (frame.size.height < minSize.height) {
                                frame.size.height = minSize.height;
                            } else {
                                frame.origin.y -= [event deltaY];
                            }
                            break;
                        case noY:
                            // nothing to do
                            break;
                        default:
                            [NSException raise:@"Unknown yResizeSection" format:@"No case for %d", resizeSection.yResizeDirection];
                    }

                    [wnd setFrame:frame display:YES];

                    break;
                }
            }

            case NSLeftMouseUp:
                // post-drag, we need to really convince the dragged window to stay in front
                [event.window makeKeyAndOrderFront:self];
                break;

            case NSRightMouseUp:
                break;

            default:
                eventHandled = false;
        }
    }

    if (!eventHandled) {
        // we didn't intercept this event; return it to its regular code path
        [self moveResizeSendEvent:event];
    }
}

@end