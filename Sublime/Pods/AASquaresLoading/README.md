# AASquaresLoading
Simple loading animation using squares

![Screenshot](screenshot.gif)

## Example
```swift
let loadingSquare = AASquaresLoading(target: self.view, size: 40)
// Customize background
loadingSquare.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
// Customize color
loadingSquare.color = UIColor.whiteColor()
// Start loading
loadingSquare.start()
....
// Stop loading
loadingSquare.stop()
```

More examples in the demo project.

## Installation

### CocoaPods

1. Add to your podfile : `pod 'AASquaresLoading'`
2. In your terminal : `pod install`

### Manual

1. Add `AASquaresLoading.swift` to your project
2. That's all you can use it!

## Usage

### Basic

1. As a UIView method

	```swift
	self.view.squareLoading.start(0.0)
	...
	self.view.squareLoading.stop(0.0)
	```
2. As a standalone class

	```swift
	let loadingSquare = AASquaresLoading(target: self.view, size: 40)
    loadingSquare.start()
    ....
    loadingSquare.stop()
	```
3. As a custom class interface builder by setting AASquareLoading as a custom class for a UIView

### Customization

##### Change background color
```swift
self.view.squareLoading.backgroundColor = UIColor.redColor()
```
##### Change squares color
```swift
self.view.squareLoading.color = UIColor.whiteColor()
```
##### Change the square size
```swift
self.view.squareLoading.setSquareSize(120)
```

## License

The MIT License (MIT)

Copyright (c) 2015 Anas AIT-ALI

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.