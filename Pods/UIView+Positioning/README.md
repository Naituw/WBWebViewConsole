UIView-Positioning
================
**UIView+Positioning** is an Objective-C Category which provides easy shorthand methods to defining the frame properties (width, height, x, y) of any UIView based object in an easy fashion, as well as extra helpful properties and methods.

Swift
-----
A pure-Swift version is available in the ['swift' branch]. If you're currently targeting iOS >= 7, you might as well use the Swift version which will most likely replace the Objecive-C version as time passes by.

USAGE
-----
Just use the properties **x**, **y**, **width**, **height** or use **origin** and **size** to kill two birds with one stone ;-)

```objc
UIButton *btnTest; // Or any other view

btnTest.width   = 250;
btnTest.height  = 100;

btnTest.y      -= 100;
btnTest.x      += 35;

btnTest.centerX = 20;
btnTest.centerY = 15;

btnTest.size    = CGSizeMake(150, 70);
btnTest.origin  = CGPointMake(25, 10);

NSLog(@"%f", btnTest.lastSubviewOnX.x); // X value of the object with the largest X value
NSLog(@"%f", btntest.lastSubviewOnY.y); // Y value of the object with the largest Y value

[btnTest centerToParent]; // Centers button to its parent view, if exists
```

Here's another short example of using **centerToParent** and the Fibonacci Series to create multiple subviewed squares
```objc
__weak UIView *currentView  = self.view;
CGFloat currentSize         = 300;

for(uint i=0; i <= 12; i++){
    UIView *newView         = [UIView new];
    newView.size            = CGSizeMake(currentSize, currentSize);
    newView.backgroundColor = [UIColor randomColor];
    [currentView addSubview: newView];
    [newView centerToParent];

    currentView             = newView;
    currentSize            -= ([self fibonacci: i+6] / 10);
}
```

Will result in this:

![Fibonacci Views](http://i61.tinypic.com/29gmnih.jpg)

AVAILABLE PROPERTIES & METHODS
-----
- **x**, **y**, **origin** - Positioning Shorthand
- **width**, **height**, **size** - Sizing Shorthand
- **left**, **bottom**, **top**, **right** - Representing X and Y values of the different sides of the view
- **centerX**, **centerY** - Shorthand for the X and Y of the View's Center
- **boundsWidth**, **boundsHeight** - Shorthand for the width and height of the View's bounds
- **boundsX**, **boundsY** - Shorthand for the X and Y position of the View's bounds
- **lastSubviewOnX**, **lastSubviewOnY** - Returns the Subview with the height X or Y value (closest to the right or closest to the bottom)

- **centerToParent** - Center the current view relatively to his superview, if one exists

PORTS
-----
* [UIView+Positioning for Xamarin] by [Cameron Ray (@camray)]

LICENSE
-------------------

Copyright (C) 2013 Developed by Shai Mishali

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

[UIView+Positioning for Xamarin]:https://github.com/camray/Xamarin-UIView-Positioning
[Cameron Ray (@camray)]:https://github.com/camray
['swift' branch]:https://github.com/freak4pc/UIView-Positioning/tree/swift
