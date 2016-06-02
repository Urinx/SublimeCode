/*
 The MIT License (MIT)
 
 Copyright (c) 2015 Stuart Crook
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SJCPDFViewMode) {
    kSJCPDFViewModeContinuous,
    kSJCPDFViewModePageVertical,
    kSJCPDFViewModePageHorizontal,
};

IB_DESIGNABLE

@interface SJCSimplePDFView : UIScrollView

// name of a file in the app's bundle to display
@property (nonatomic,strong) IBInspectable NSString *PDFBundleFileName;

// URL pointing to the file to display
@property (nonatomic,strong) NSURL *PDFFileURL;

// the raw PDF data
@property (nonatomic,copy) NSData *PDFData;

#if !TARGET_INTERFACE_BUILDER
// defaults to kSJCPDFViewModeContinuous
@property (nonatomic)  SJCPDFViewMode viewMode;
#else
@property (nonatomic) IBInspectable NSUInteger viewMode;
#endif

// current visible page (topmost page for kSJCPDFViewModeContinuous)
// KVO-able, in case you want to track user interaction with the view
@property (nonatomic) NSUInteger currentPage;

// a set containing details of the pages currently visible
@property (nonatomic,readonly) NSIndexSet *currentPages;

// number of pages in the PDF document
@property (nonatomic,readonly) NSUInteger documentPageCount;

// a set containing the pages which can be displayed. nil means display all
@property (nonatomic,copy) NSIndexSet *displayPages;

// number of pages from the PDF document which are available for display
@property (nonatomic,readonly) NSUInteger displayedPageCount;

// margin around each page
@property (nonatomic) UIEdgeInsets pageInsets;
// because IBDesignable needs a little more work
@property (nonatomic) IBInspectable CGFloat topPageInset;
@property (nonatomic) IBInspectable CGFloat bottomPageInset;
@property (nonatomic) IBInspectable CGFloat leftPageInset;
@property (nonatomic) IBInspectable CGFloat rightPageInset;

@property (nonatomic,strong) IBInspectable UIColor *pageBackgroundColour;

// these are only visible if edge insets are non-zero
@property (nonatomic,strong) IBInspectable UIColor *borderColour;
@property (nonatomic) IBInspectable CGFloat borderWidth;

@end
