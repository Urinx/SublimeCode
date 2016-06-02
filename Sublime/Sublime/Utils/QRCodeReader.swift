//
//  QRCodeReader.swift
//  Sublime
//
//  Created by Eular on 5/4/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

class QRCodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    let messageLabel = UILabel()
    var isQRCodeRecognized: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "QRCode"
        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let input: AVCaptureInput
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch { return }
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input)
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        qrCodeFrameView?.frame = CGRectMake(0, 0, 230, 230)
        qrCodeFrameView?.center = view.center
        qrCodeFrameView?.y -= Constant.NavigationBarOffset
        qrCodeFrameView?.layer.borderColor = UIColor.whiteColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 1
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
        
        // Initialize qrcode result label
        messageLabel.frame = CGRectMake(0, view.height - Constant.NavigationBarOffset - 40, view.width, 40)
        messageLabel.backgroundColor = Constant.BlackMaskViewColor
        messageLabel.textColor = UIColor.whiteColor()
        messageLabel.textAlignment = .Center
        messageLabel.font = UIFont.systemFontOfSize(15)
        messageLabel.numberOfLines = 2
        messageLabel.text = "No QR code is detected"
        view.addSubview(messageLabel)
        
        // Start video capture.
        captureSession?.startRunning()
    }
    
    override func viewWillAppear(animated: Bool) {
        isQRCodeRecognized = false
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if !isQRCodeRecognized {
            // Check if the metadataObjects array is not nil and it contains at least one object.
            if metadataObjects == nil || metadataObjects.count == 0 {
                messageLabel.text = "No QR code is detected"
                return
            }
            
            // Get the metadata object.
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            if metadataObj.type == AVMetadataObjectTypeQRCode {
                // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
                /*
                 let barCodeObject =
                 videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj) as!
                 AVMetadataMachineReadableCodeObject
                 qrCodeFrameView?.frame = barCodeObject.bounds
                 */
                
                if let qrStr = metadataObj.stringValue {
                    isQRCodeRecognized = true
                    messageLabel.text = qrStr
                    
                    
                    var mySound: SystemSoundID = 0
                    
                    if let url = NSBundle.mainBundle().URLForResource("qrcode_scan", withExtension: "wav") {
                        AudioServicesCreateSystemSoundID(url, &mySound)
                        AudioServicesPlaySystemSound(mySound)
                    }
                    
                    if let url = NSURL(string: qrStr) {
                        let svc = SublimeSafari(URL: url)
                        navigationController?.pushViewController(svc, animated: true)
                    }
                }
            }
        }
    }
}
