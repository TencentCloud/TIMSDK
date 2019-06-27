# ISVImageScrollView

[![CI Status](http://img.shields.io/travis/kupratsevich@gmail.com/ISVImageScrollView.svg?style=flat)](https://travis-ci.org/kupratsevich@gmail.com/ISVImageScrollView)
[![Version](https://img.shields.io/cocoapods/v/ISVImageScrollView.svg?style=flat)](http://cocoapods.org/pods/ISVImageScrollView)
[![License](https://img.shields.io/cocoapods/l/ISVImageScrollView.svg?style=flat)](http://cocoapods.org/pods/ISVImageScrollView)
[![Platform](https://img.shields.io/cocoapods/p/ISVImageScrollView.svg?style=flat)](http://cocoapods.org/pods/ISVImageScrollView)

A subclass of the UIScrollView tweaked for image preview with zooming, scrolling and rotation support.

## Overview

When you need to incorporate an image preview into your application, usually you start with the UIScrollView and then spend hours tweaking it to get functionality similar to the default Photos app. This control provides you out-of-the-box functionality to zoom, scroll and rotate an UIImageView attached to it.

## Features

* Pinch to zoom and scroll
* Tap to zoom
* Scale image when scroll view bounds change, e.g. after rotation
* Set appropriate content offset after rotation to make sure visible content remains the same

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* Tested on iOS 9.3 and higher, but should work on iOS 8.x as well

## Installation

ISVImageScrollView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ISVImageScrollView'
```

## Usage

ISVImageScrollView is very easy to use.
1. Create a __UIImageView__ instance and assign it an image.
2. Create an __ISVImageScrollView__ instance (either programmatically or via the Storyboard/XIB) and assign the created UIImageView object to its __imageView__ property.
3. Don't forget to set __maximumZoomScale__ and __delegate__ properties of the ISVImageScrollView instance.
4. Finally in delegate class implement __viewForZoomingInScrollView:__ method and return the UIImageView object created in step 1.

```objc
UIImage *image = [UIImage imageNamed:@"Photo.jpg" inBundle:nil compatibleWithTraitCollection:nil];
self.imageView = [[UIImageView alloc] initWithImage:image];
self.imageScrollView.imageView = self.imageView;
self.imageScrollView.maximumZoomScale = 4.0;
self.imageScrollView.delegate = self;
```
```objc
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}
```

## Author

Yurii Kupratsevych

kupratsevich@gmail.com

## License

ISVImageScrollView is available under the MIT license. See the LICENSE file for more info.
