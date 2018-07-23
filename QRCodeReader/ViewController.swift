//
//  ViewController.swift
//  QRCodeReader
//
//  Created by Qiaokai on 2017/1/20.
//  Copyright © 2017年 QianBao. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode]
    
    lazy var label: UILabel = {
        let label: UILabel = UILabel()
        label.frame = CGRect(x: 100, y: 20, width: 100, height: 20)
        label.textColor = .black
        return label
    }()
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let captureMetadataoutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataoutput)
            
            captureMetadataoutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataoutput.metadataObjectTypes = supportedCodeTypes;
            
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.frame.size = CGSize(width: 200, height: 200)
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
                qrCodeFrameView.center = view.center
            }
            
            
        } catch {
            print(error)
        }
        
        
        view.addSubview(label)
        view.bringSubview(toFront: label)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.isEmpty {
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            if qrCodeFrameView!.frame.contains(barCodeObject!.bounds) {
                if metadataObj.stringValue != nil {
                    label.text = metadataObj.stringValue
                }
            }
        }
    }
}
