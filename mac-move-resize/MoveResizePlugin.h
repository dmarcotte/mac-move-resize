#import <Foundation/Foundation.h>

enum ResizeDirectionX {
    right,
    left,
    noX
};

enum ResizeSectionY {
    top,
    bottom,
    noY
};

struct ResizeSection {
    enum ResizeDirectionX xResizeDirection;
    enum ResizeSectionY yResizeDirection;
};

@interface MoveResizePlugin : NSObject {
    struct ResizeSection _resizeSection;
}

+ (id) sharedInstance;

@property struct ResizeSection resizeSection;

@end