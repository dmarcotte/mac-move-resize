# Easy Move/Resize for Mac

Adds easy `modifier key + mouse click` move/resize capabilities to OSX

## Usage
This enhancement is based on behavior found in many X11 window managers:
* `Cmd + Ctrl + Left Mouse Click` anywhere inside a window, then drag to move
* `Cmd + Ctrl + Right Mouse Click` anywhere inside a window, then drag to resize (the resize direction is determined by which region of the window is clicked.  i.e. a right-click in roughly the top-left corner of a window will act as if you grabbed the top left corner, whereas a right-click in roughly the top-center of a window will act as if you grabbed the top of the window)

## Installation
* To install:
    * Download and install [SIMBL](http://www.culater.net/software/SIMBL/SIMBL.php)
    * Download the latest version of [Easy Move/Resize](https://sourceforge.net/projects/mac-move-resize/files/mac-move-resize_1.0.bundle.zip/download) and unzip it in `~/Library/Application Support/SIMBL/Plugins`
    * Restart any applications
* To uninstall:
    * Delete `~/Library/Application Support/SIMBL/Plugins/mac-move-resize_1.0.bundle`

## Known issues
* Being a [SIMBL](http://www.culater.net/software/SIMBL/SIMBL.php) plugin, **Easy Move/Resize** is restricted to Cocoa apps
* **Easy Move/Resize** is subject to [SIMBL's known issues](http://code.google.com/p/simbl/issues/list)

## Acknowledgement
This utility is based on the move/resize code in @millenomi's [Afloat](https://github.com/millenomi/afloat)
