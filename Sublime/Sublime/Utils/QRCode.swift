//
//  QRCode.swift
//  Sublime
//
//  Created by Eular on 4/1/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation
import CoreGraphics

class QRCode {
    func make(str: String, size: CGFloat = 250) -> UIImage {
        let qrcode = createNonInterpolatedUIImageFormCIImage(createQRForString(str), withSize: size)
        return qrcode
    }
    
    func makeWithColor(str: String, size: CGFloat = 250, R: CGFloat = 60, G: CGFloat = 74, B: CGFloat = 89) -> UIImage {
        let qrcode = createNonInterpolatedUIImageFormCIImage(createQRForString(str), withSize: size)
        let customQrcode = imageBlackToTransparent(qrcode, red: R, green: G, blue: B)
        return customQrcode
    }
    
    func hasQRCode(img: UIImage) -> Bool {
        let ciImg = CIImage(image: img)
        let context = CIContext(options: nil)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        let features = detector.featuresInImage(ciImg!)
        return features.count != 0
    }
    
    func read(img: UIImage) -> String? {
        let ciImg = CIImage(image: img)
        let context = CIContext(options: nil)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        let features = detector.featuresInImage(ciImg!)
        
        if features.count != 0 {
            return (features[0] as! CIQRCodeFeature).messageString
        } else {
            return nil
        }
    }
    
    private func createQRForString(QRStr: String) -> CIImage {
        // Need to convert the string to a UTF-8 encoded NSData object
        let strData = QRStr.dataUsingEncoding(NSUTF8StringEncoding)
        // Create the filter
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        // Set the message content and error-correction level
        qrFilter.setValue(strData, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        // Send the image back
        return qrFilter.outputImage!
    }
    
    private func createNonInterpolatedUIImageFormCIImage(image: CIImage, withSize size: CGFloat) -> UIImage {
        let extent = CGRectIntegral(image.extent)
        let scale = min(size / extent.width, size / extent.height)
        // create a bitmap image that we'll draw into a bitmap context at the desired size;
        let width = extent.width * scale
        let height = extent.height * scale
        let cs = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, cs, CGImageAlphaInfo.None.rawValue)
        let context = CIContext(options: nil)
        let bitmapImage = context.createCGImage(image, fromRect: extent)
        CGContextSetInterpolationQuality(bitmapRef, .None)
        CGContextScaleCTM(bitmapRef, scale, scale)
        CGContextDrawImage(bitmapRef, extent, bitmapImage)
        // Create an image with the contents of our bitmap
        let scaledImage = CGBitmapContextCreateImage(bitmapRef)
        // Cleanup
        // CGContext instances are automatically memory managed in Swift
        return UIImage(CGImage: scaledImage!)
    }
    
    private func imageBlackToTransparent(image: UIImage, red: CGFloat, green: CGFloat, blue: CGFloat) -> UIImage {
        let imageWidth = Int(image.size.width)
        let imageHeight = Int(image.size.height)
        let bytesPerRow = imageWidth * 4
        
        let rgbImageBuf = UnsafeMutablePointer<UInt32>.alloc(imageWidth * imageHeight)
        
        // create context
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.NoneSkipLast.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue)
        let context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: image.size), image.CGImage)
        
        // traverse pixe
        let pixelNum = imageWidth * imageHeight;
        var pCurPtr = UnsafeMutablePointer<UInt32>(rgbImageBuf)
        
        var i = 0
        while i < pixelNum {
            if ((pCurPtr.memory & 0xFFFFFF00) < 0x99999900){
                // change color
                let ptr = (UnsafeMutablePointer<UInt8>)(pCurPtr)
                ptr[3] = UInt8(red)
                ptr[2] = UInt8(green)
                ptr[1] = UInt8(blue)
            }else{
                let ptr = UnsafeMutablePointer<UInt8>(pCurPtr)
                ptr[0] = 0;
            }
            
            i += 1
            pCurPtr += 1
        }
        
        let dataProvider = CGDataProviderCreateWithData(nil, rgbImageBuf, bytesPerRow * imageHeight, nil)
        let imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace, bitmapInfo, dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
        let resultImage = UIImage(CGImage: imageRef!)
        
        return resultImage
    }
}
