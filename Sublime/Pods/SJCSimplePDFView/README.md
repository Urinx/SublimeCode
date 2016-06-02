# SJCSimplePDFView
A simple UIView subclass for displaying PDFs on iOS. I created this for a project when displaying a PDF in a UIWebView didn't provide either the styling options or feedback required.

The PDFView:

* Provides 3 different display modes
* Allows customisation of page backgrounds, borders and insets
* Allows display to be limited to a subset of pages within a PDF document
* Allows observation of visible page number (or numbers)
* Integrates with Interface Builder (mostly IBInspectable)

This repository contains an example app which you can use to play around with the PDFView's settings to see what it can do.

Installation
------------

Copy the `SJCSimplePDFView.h` and `SJCSimplePDFView.m` files into your project.

(Cocopods integration coming soon.)

Use
---

The PDFView can be created and configured via Interface Builder, or in code (using `-initWithFrame:`).

A PDF document can be loaded into the PDFView in one of 3 ways:

* Set the `.PDFData` property to an NSData object containing a PDF file.
* Set the `.PDFFileURL` to the URL of a PDF document. Note that this should be a local file URL (file://...). An exception will be thrown if you attempt to set this value with any other URL.
* Set the `.PDFBundleFileName` property to the filename of a PDF document included in your app bundle. This property can also be set in Interface Builder (although the content of the PDF is not currently shown in Interface Builder).

`.viewMode` can be specified in Interface Builder. (Due to current limitations with working with enums this is an integer field which can take any value. Only the values noted in brackets below are valid, other values will be interpreted as 0.) It has 3 possible display modes:
* `kSJCPDFViewModeContinuous` [0] -- pages are displayed end-to-end, with width set to the widht of the PDFView, and scroll vertically
* `kSJCPDFViewModePageVertical` [1] -- pages are displayed individually, scaled to fit the PDFView, and scroll vertically
* `kSJCPDFViewModePageHorizontal` [2] -- pages are displayed individually, scaled to fit the PDFView, and scroll horizontally

Once a document is set, the number of pages it contain can be found in `.documentPageCount`. By default, all pages from the document are shown. To display only a subset of pages, set `.displayPages` to a NSIndexSet containing the page numbers to display. `.displayedPageCount` contains the number of pages from the document which will actually be displayed.

`.currentPage` is the number of the page currently displayed. If more than one page can be visible at once (if `.viewMode` is `kSJCPDFViewModeContinuous`) `.currentPages` returns as NSIndexSet containing the page numbers of all the visible pages (in other modes it returns an NSIndexSet containing only `.currentPage`). Page numbers start at 1 and are based on the `.displayedPages`, not a page's position in the PDF document, so if you are only showing pages 21-25 of a document `.currentPage` will report these as pages 1-5. Setting `.currentPage` changes the displayed page, as long as the new value is between 1 and `.displayedPageCount` inclusive.

If you would like to track user interaction with the PDFView, `.currentPage` is KVO compliant (see the example app).

The inset of a page from the edges of the PDFView can be set via `.pageInsets`. The background of this inset area can be set with `.pageBackgroundColour`. (Note that most PDFs with white backgrounds are effectively transparent.) The width and colour of the border drawn around this inset area can be specified with `.borderColour` and `.borderWidth`. All of these properties can be set in Interface Builder.
