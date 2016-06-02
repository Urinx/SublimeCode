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

#import "SJCSimplePDFView.h"

// distance outside content view to add extra page views
static CGFloat const PageCachingMargin = 100.f;
static CGFloat const DoublePageCachingMargin = PageCachingMargin * 2.f;

@interface SJCSimplePDFView () <UIScrollViewDelegate>

@property (nonatomic,assign) CGPDFDocumentRef document;

@property (nonatomic) NSUInteger documentPageCount;
@property (nonatomic) NSUInteger displayedPageCount;

@property (nonatomic,strong) UIView *pagesContainer;
@property (nonatomic,strong) NSArray *pages;
@property (nonatomic,strong) NSArray *pageFrames;
@property (nonatomic,strong) NSMutableDictionary *pageViews;

@property (nonatomic) CGSize lastLaidOutSize;

@property (nonatomic,assign) CGColorSpaceRef cs;

@property (nonatomic,weak) NSObject <UIScrollViewDelegate> *externalDelegate;

@end

@implementation SJCSimplePDFView

#pragma mark - lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder])) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    _pagesContainer = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_pagesContainer];
    
    super.delegate = self;
    
    _cs = CGColorSpaceCreateDeviceRGB();
}

- (void)dealloc {
    if(_document) {
        CGPDFDocumentRelease(_document);
        _document = NULL;
    }
    if(_cs) {
        CGColorSpaceRelease(_cs);
        _cs = NULL;
    }
}

#pragma mark - setting the document

- (void)setPDFBundleFileName:(NSString *)PDFBundleFileName {
    NSParameterAssert(PDFBundleFileName.length);
    
#if TARGET_INTERFACE_BUILDER
    NSURL *fileURL = [[NSBundle bundleForClass:[self class]] URLForResource:[PDFBundleFileName stringByDeletingPathExtension] withExtension:[PDFBundleFileName pathExtension]];
#else
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:[PDFBundleFileName stringByDeletingPathExtension] withExtension:[PDFBundleFileName pathExtension]];
#endif
    if(!fileURL) {
        NSLog(@"error: unable to find '%@' in the main app bundle", PDFBundleFileName);
        return;
    }
    
    self.PDFFileURL = fileURL;
    _PDFBundleFileName = PDFBundleFileName;
}

- (void)setPDFFileURL:(NSURL *)PDFFileURL {
    NSParameterAssert(PDFFileURL.isFileURL);

    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:PDFFileURL options:NSDataReadingMappedIfSafe error:&error];
    if(!data) {
        NSLog(@"error loading data from URL %@: %@", PDFFileURL, error);
        return;
    }
    if(!data.length) {
        NSLog(@"error: loading %@ resulted in 0-length data", PDFFileURL);
        return;
    }
    
    self.PDFData = data;
    _PDFBundleFileName = nil;
    _PDFFileURL = PDFFileURL;
}

- (void)setPDFData:(NSData *)PDFData {
    NSParameterAssert(PDFData.length);
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)PDFData);
    CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(provider);
    CGDataProviderRelease(provider);
    if(!document) {
        NSLog(@"error creating PDF document from data");
        return;
    }
    
    _PDFFileURL = nil;
    _PDFData = PDFData;
    _document = document;

    [self _configureForDocument];
}

// setup values which are derived from the current PDF document
- (void)_configureForDocument {

    _documentPageCount = CGPDFDocumentGetNumberOfPages(_document);
    if(!_documentPageCount) {
        NSLog(@"warning: document has no pages!");
        return; // not much else we can do...
    }
    _currentPage = 1;
    
    NSMutableArray *pages = [NSMutableArray new];
    if(_displayPages) {
        [_displayPages enumerateIndexesInRange:NSMakeRange(1, _documentPageCount)
                                       options:kNilOptions
                                    usingBlock:^(NSUInteger page, BOOL *stop) {
            [pages addObject:(__bridge id)CGPDFDocumentGetPage(_document, page)];
        }];
        
    } else {
        NSUInteger page = 1;
        while(page <= _documentPageCount) {
            [pages addObject:(__bridge id)CGPDFDocumentGetPage(_document, page++)];
        }
    }
    _pages = [pages copy];
    _displayedPageCount = _pages.count;

    [self _resetPageViews];

    self.contentOffset = CGPointZero;
}

- (void)_resetPageViews {
    [_pageViews.allValues enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    _pageViews = [NSMutableDictionary new];
    _pageFrames = nil;
}

#pragma mark - IB_DESIGNABLE

#if TARGET_INTERFACE_BUILDER
- (void)prepareForInterfaceBuilder {
    if(!_PDFData.length) {
        // create a blank A4 PDF page to display as example content
        self.PDFData = ({
            NSMutableData *data = [NSMutableData new];
            CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
            CGRect box = (CGRect){ CGPointZero, CGSizeMake(210.f * 72.0f * 0.393700787f, 297.f * 72.0f * 0.393700787f) };
            CGContextRef context = CGPDFContextCreate(consumer, &box, NULL);
            CGPDFContextBeginPage(context, NULL);
            CGPDFContextEndPage(context);
            CGPDFContextClose(context);
            CGContextRelease(context);
            CGDataConsumerRelease(consumer);
            data;
        });
    }
}
#endif

#pragma mark - 

- (void)setDisplayPages:(NSIndexSet *)displayPages {
    _displayPages = [displayPages copy];
    [self _resetPageViews];
    [self setNeedsLayout];
}

- (void)setViewMode:(SJCPDFViewMode)viewMode {

    // sanity check because of the hoops we're jumping through to make this IBInspectable
    if(viewMode < kSJCPDFViewModeContinuous || viewMode > kSJCPDFViewModePageHorizontal) {
        return;
    }
    
    if(_viewMode != viewMode) {
        // do basic configuration for the new mode
        switch((_viewMode = viewMode)) {
            case kSJCPDFViewModeContinuous:
                self.pagingEnabled = NO;
                break;
                
            case kSJCPDFViewModePageHorizontal:
            case kSJCPDFViewModePageVertical:
                self.pagingEnabled = YES;
                break;
        }
        
        // most other view configuration happens in -didLayoutSubviews
        [self _resetPageViews];
        [self setNeedsLayout];
    }
}


- (void)setCurrentPage:(NSUInteger)currentPage {
    if(_currentPage != currentPage && (_displayPages == nil || [_displayPages containsIndex:currentPage])) {
        _currentPage = currentPage;
        self.contentOffset = ({
            CGSize size = UIEdgeInsetsInsetRect(self.bounds, self.contentInset).size;
            CGPoint offset;
            switch(_viewMode) {
                case kSJCPDFViewModeContinuous:
                    offset = [_pageFrames[currentPage - 1] CGRectValue].origin;
                    offset.x = 0.f;
                    offset.y = offset.y - _pageInsets.right - self.contentInset.top;
                    break;
                    
                case kSJCPDFViewModePageVertical:
                    offset = CGPointMake(0.f, size.height * currentPage);
                    break;
                    
                case kSJCPDFViewModePageHorizontal:
                    offset = CGPointMake(size.width * currentPage, 0.f);
                    break;
            }
            offset;
        });
        [self _configureVisiblePages];
    }
}

// the pages which are (should be) visible
- (NSIndexSet *)currentPages {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
    CGRect visibleRect = UIEdgeInsetsInsetRect((CGRect){ self.contentOffset, self.bounds.size }, self.contentInset);
    [_pageViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, UIView *view, BOOL *stop) {
        if(CGRectIntersectsRect(visibleRect, view.frame)) {
            [indexSet addIndex:view.tag];
        }
    }];
    return [indexSet copy];
}

#pragma mark - view layout

- (void)setNeedsLayout {
    _lastLaidOutSize = CGSizeZero;
    [super setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = UIEdgeInsetsInsetRect((CGRect){ CGPointZero, self.bounds.size }, self.contentInset);
    
    if(CGSizeEqualToSize(_lastLaidOutSize, bounds.size)) {
        return; // we've already laid out for this view size
    }
    
    _lastLaidOutSize = bounds.size;
    
    CGSize __block contentSize;
    CGPoint __block contentOffset;
    
    NSMutableArray *pageFrames = [NSMutableArray new];

    switch(_viewMode) {
        case kSJCPDFViewModeContinuous: {
            
            // scrollable content will be as wide as the view
            contentSize = CGSizeMake(bounds.size.width, 0.f);
            
            // calculate what we can about the size of the first page: its width and x position
            CGRect __block pageFrame = CGRectMake(_pageInsets.left, 0.f, contentSize.width - _pageInsets.left - _pageInsets.right, 0.f);
            
            [_pages enumerateObjectsUsingBlock:^(id page, NSUInteger index, BOOL *stop) {

                CGSize pageSize = CGPDFPageGetBoxRect((__bridge CGPDFPageRef)page, kCGPDFMediaBox).size;

                int rotation = CGPDFPageGetRotationAngle((__bridge CGPDFPageRef)page);
                if(rotation == 90 || rotation == 270) {
                    pageSize = CGSizeMake(pageSize.height, pageSize.width);
                }
                
                pageFrame.origin.y += _pageInsets.top;
                pageFrame.size.height = roundf(pageFrame.size.width * (pageSize.height / pageSize.width));
                [pageFrames addObject:[NSValue valueWithCGRect:pageFrame]];
                
                UIView *view = _pageViews[@(index)];
                if(view) { view.frame = pageFrame; }
                
                if(_currentPage - 1 == index) {
                    contentOffset = CGPointMake(0.f, pageFrame.origin.y - _pageInsets.top);
                }
                
                // advance to the next page frame position
                pageFrame.origin.y += pageFrame.size.height + _pageInsets.bottom;
            }];
            
            contentSize.height = pageFrame.origin.y;
            
        } break;
            
        case kSJCPDFViewModePageVertical:
        case kSJCPDFViewModePageHorizontal: {
            
            CGFloat xd = 0.f;
            CGFloat yd = 0.f;
            
            // code paths for these modes are mostly the same, except for this bit
            if(_viewMode == kSJCPDFViewModePageHorizontal) {
                xd = bounds.size.width;
                contentSize = CGSizeMake(bounds.size.width * _displayedPageCount, bounds.size.height);
                contentOffset = CGPointMake(bounds.size.width * (_currentPage - 1), 0.f);
            } else {
                yd = bounds.size.height;
                contentSize = CGSizeMake(bounds.size.width, bounds.size.height * _displayedPageCount);
                contentOffset = CGPointMake(0.f, bounds.size.height * (_currentPage - 1));
            }

            CGRect __block pageFrame = UIEdgeInsetsInsetRect(bounds, _pageInsets);
            
            [_pages enumerateObjectsUsingBlock:^(id page, NSUInteger index, BOOL *stop) {
                
                CGSize pageSize = CGPDFPageGetBoxRect((__bridge CGPDFPageRef)page, kCGPDFMediaBox).size;

                // calculate the page frame which fits -- attempt to fit full height first
                CGRect frame;
                CGFloat width = roundf(pageFrame.size.height * (pageSize.width / pageSize.height));
                if(width <= pageFrame.size.width) {
                    // fits, so adjust x offsets
                    frame = CGRectMake(pageFrame.origin.x + roundf((pageFrame.size.width - width) / 2.f), pageFrame.origin.y, width, pageFrame.size.height);
                } else {
                    // doesn't fit, so assume we're fitting across full width
                    CGFloat height = roundf(pageFrame.size.width * (pageSize.height / pageSize.width));
                    frame = CGRectMake(pageFrame.origin.x, pageFrame.origin.y + roundf((pageFrame.size.height - height) / 2.f), pageFrame.size.width, height);
                }
                [pageFrames addObject:[NSValue valueWithCGRect:frame]];
                
                UIView *view = _pageViews[@(index)];
                if(view) { view.frame = frame; }
                
                // advance to the next page frame position
                pageFrame.origin.x += xd;
                pageFrame.origin.y += yd;
            }];

        } break;
            
        default:
            return;
            break;
    }

    _pageFrames = [pageFrames copy];

    _pagesContainer.frame = (CGRect){ CGPointZero, contentSize };

    self.contentSize = contentSize;
    //self.contentOffset = contentOffset;
    
    [self _configureVisiblePages];
}

- (void)_configureVisiblePages {
    
    // calculate the visible part of the scrollview, plus an overlap which will cache the neighbouring views
    CGFloat zoom = self.zoomScale;
    CGPoint offset = ({
        CGPoint offset = self.contentOffset;
        UIEdgeInsets insets = self.contentInset;
        offset.x += insets.left;
        offset.y += insets.top;
        offset;
    });
    CGSize visible = UIEdgeInsetsInsetRect(self.bounds, self.contentInset).size;
    CGRect visibleRect = CGRectMake(offset.x / zoom, offset.y / zoom, visible.width / zoom, visible.height / zoom);
    if(_viewMode == kSJCPDFViewModePageHorizontal) {
        visibleRect.origin.x -= PageCachingMargin;
        visibleRect.size.width += DoublePageCachingMargin;
    } else {
        visibleRect.origin.y -= PageCachingMargin;
        visibleRect.size.height += DoublePageCachingMargin;
    }
    
    // calculate which views should be visible and add them to the scrollview
    NSMutableIndexSet *visibleViewIdexes = [NSMutableIndexSet new];
    [_pageFrames enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger index, BOOL *stop) {
        if(CGRectIntersectsRect(visibleRect, value.CGRectValue)) {
            [visibleViewIdexes addIndex:index];
            [self _displayPageAtIndex:index];
        }
    }];

    // remove the views which should no longer be visible
    NSMutableIndexSet *removableViewIndexes = [NSMutableIndexSet new];
    [_pageViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *index, UIView *view, BOOL *stop) {
        NSUInteger i = index.integerValue;
        if(![visibleViewIdexes containsIndex:i]) {
            [removableViewIndexes addIndex:i];
            [view removeFromSuperview];
        }
    }];
    [removableViewIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        [_pageViews removeObjectForKey:@(index)];
    }];
    
    // work out what the current visible page is
    NSUInteger currentPage = self.currentPages.firstIndex;
    if(currentPage != _currentPage) {
        [self willChangeValueForKey:@"currentPage"];
        _currentPage = currentPage;
        [self didChangeValueForKey:@"currentPage"];
    }
}

// index is 0-based and describes the page's position within the scrollview. it
// is not necessarily directly related to the PDF page number
- (void)_displayPageAtIndex:(NSUInteger)index {
    
    if(index >= _pages.count) {
        return; // no such page
    }
    
    // the .pageViews dictionary stores using the index, to make this easier
    if(_pageViews[@(index)]) {
        return; // view already exists
    }
    
    // get details about the page we'll be displaying
    CGPDFPageRef page = (__bridge CGPDFPageRef)_pages[index];
    CGRect pageFrame = [_pageFrames[index] CGRectValue];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:pageFrame];
    imageView.backgroundColor = _pageBackgroundColour;
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.tag = CGPDFPageGetPageNumber(page);; // makes -visiblePages a bit easier
    [self configureLayerBorderForView:imageView];
    [_pagesContainer addSubview:imageView];
    
    _pageViews[@(index)] = imageView;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // calculate pixel size, taking into account how far in we could zoom
        CGFloat scale = [UIScreen mainScreen].scale * self.maximumZoomScale;
        CGSize size = CGSizeMake(pageFrame.size.width * scale, pageFrame.size.height * scale);

        CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width * 4, _cs, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);

        CGSize mediaSize = CGPDFPageGetBoxRect(page, kCGPDFMediaBox).size;
        int rotation = CGPDFPageGetRotationAngle(page);
        if(rotation == 90 || rotation == 270) {
            mediaSize = CGSizeMake(mediaSize.height, mediaSize.width);
        }

        CGContextScaleCTM(context, size.width / mediaSize.width, size.height / mediaSize.height );
        CGContextTranslateCTM(context, (mediaSize.width - size.width) / 2.f, (mediaSize.height - size.height) / 2.f);
        CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, (CGRect){ CGPointZero, size }, 0, true));
        
        CGContextDrawPDFPage(context, page);
        
        CGImageRef cgImage = CGBitmapContextCreateImage(context);
        UIImage *image = [UIImage imageWithCGImage:cgImage];

        CGImageRelease(cgImage);
        CGContextRelease(context);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    });
}

#pragma mark - page view attributes

- (void)setPageInsets:(UIEdgeInsets)pageInsets {
    if(!UIEdgeInsetsEqualToEdgeInsets(_pageInsets, pageInsets)) {
        _pageInsets = pageInsets;
        [self setNeedsLayout];
    }
}

// because UIEdgeInsets cannot be IBInspectable
// TODO: radar this

- (void)setTopPageInset:(CGFloat)topPageInset {
    if(_pageInsets.top != topPageInset) {
        _pageInsets.top = topPageInset;
        [self setNeedsLayout];
    }
}

- (CGFloat)topPageInset {
    return _pageInsets.top;
}

- (void)setBottomPageInset:(CGFloat)bottomPageInset {
    if(_pageInsets.bottom != bottomPageInset) {
        _pageInsets.bottom = bottomPageInset;
        [self setNeedsLayout];
    }
}

- (CGFloat)bottomPageInset {
    return _pageInsets.bottom;
}

- (void)setLeftPageInset:(CGFloat)leftPageInset {
    if(_pageInsets.left != leftPageInset) {
        _pageInsets.left = leftPageInset;
        [self setNeedsLayout];
    }
}

- (CGFloat)leftPageInset {
    return _pageInsets.left;
}

- (void)setRightPageInset:(CGFloat)rightPageInset {
    if(_pageInsets.right != rightPageInset) {
        _pageInsets.right = rightPageInset;
        [self setNeedsLayout];
    }
}

- (CGFloat)rightPageInset {
    return _pageInsets.right;
}

- (void)setPageBackgroundColour:(UIColor *)pageBackgroundColour {
    _pageBackgroundColour = pageBackgroundColour;
    [_pageViews enumerateKeysAndObjectsUsingBlock:^(UIView *view, id obj, BOOL *stop) {
        view.backgroundColor = pageBackgroundColour;
    }];
}

- (void)setBorderColour:(UIColor *)borderColour {
    _borderColour = borderColour;
    [_pageViews enumerateKeysAndObjectsUsingBlock:^(UIView *view, id obj, BOOL *stop) {
        [self configureLayerBorderForView:view];
    }];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [_pageViews enumerateKeysAndObjectsUsingBlock:^(UIView *view, id obj, BOOL *stop) {
        [self configureLayerBorderForView:view];
    }];
}

// apply the current border setting to the given view
- (void)configureLayerBorderForView:(UIView *)view {
    CALayer *layer = view.layer;
    layer.borderColor = _borderColour.CGColor;
    layer.borderWidth = _borderWidth;
}

#pragma mark - UIScrollViewDelegate

// allow another object to act as delegate to our scrollview
- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    self.externalDelegate = delegate;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if(_viewMode == kSJCPDFViewModeContinuous) {
        [self _configureVisiblePages];
    }
    
    if([_externalDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_externalDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if(_viewMode != kSJCPDFViewModeContinuous) {
        [self _configureVisiblePages];
    }
    
    if([_externalDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [_externalDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // don't allow an external delegate to over-ride this
    return _pagesContainer;
}

// TODO: there must be a better way than all this... ;)

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if([_externalDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [_externalDelegate scrollViewDidZoom:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if([_externalDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_externalDelegate scrollViewWillBeginDragging:self];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if([_externalDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [_externalDelegate scrollViewWillEndDragging:self withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if([_externalDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_externalDelegate scrollViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if([_externalDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [_externalDelegate scrollViewWillBeginDecelerating:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if([_externalDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [_externalDelegate scrollViewDidEndScrollingAnimation:self];
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if([_externalDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [_externalDelegate scrollViewWillBeginZooming:self withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if([_externalDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [_externalDelegate scrollViewDidEndZooming:self withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if([_externalDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [_externalDelegate scrollViewShouldScrollToTop:self];
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if([_externalDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [_externalDelegate scrollViewDidScrollToTop:self];
    }
}

@end
