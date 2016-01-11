//
//  ViewController.swift
//  HoloHat
//
//  Created by Benjamin Englard on 9/12/15.
//  Copyright (c) 2015 Benjamin Englard. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let hd = HandDetect()
    let fps: Int32 = 30

    let width = UIScreen.mainScreen().bounds.width
    let height = UIScreen.mainScreen().bounds.height
    
    let session = AVCaptureSession()
    let still = AVCaptureStillImageOutput()
    var device: AVCaptureDevice?
    var videoLayer: AVCaptureVideoPreviewLayer?
    var videoConnection: AVCaptureConnection?
    
    var rightView: UIView?
    var textLayer: CATextLayer?
    
    let ball = UIImageView(image: UIImage(named: "ball"))
    let hoop = UIImageView(image: UIImage(named: "hoop"))
    
    var timer: NSTimer?
    var score = 0
    var over = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session.sessionPreset = AVCaptureSessionPreset1280x720
        for dev in AVCaptureDevice.devices() {
            if dev.hasMediaType(AVMediaTypeVideo) {
                if dev.position == AVCaptureDevicePosition.Front {
                    device = dev as? AVCaptureDevice
                }
            }
        }
        
        let w2 = width / 2
        let h2 = height / 2
        let h4 = h2 / 2
        
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        //rightView!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.view.addSubview(rightView!)
        
        videoLayer = AVCaptureVideoPreviewLayer(session: session)
        videoLayer!.frame = CGRect(x: 0, y: 0, width: width, height: height)
        videoLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        rightView!.layer.addSublayer(videoLayer)
        
        ball.frame = CGRect(x: 0, y: 0, width: 30.0, height: 30.0)
        ball.alpha = 0.7
        ball.center.x = w2
        ball.center.y = h2
        rightView!.addSubview(ball)
        
        hoop.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        hoop.alpha = 0.5
        hoop.center.x = w2
        hoop.center.y = h2
        rightView!.addSubview(hoop)
        
        textLayer = CATextLayer()
        textLayer!.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        textLayer!.string = "0"
        textLayer!.wrapped = false
        textLayer!.font = UIFont.boldSystemFontOfSize(40).fontName
        textLayer!.fontSize = 40
        textLayer!.foregroundColor = UIColor.whiteColor().CGColor
        textLayer!.position = CGPoint(x: w2 + 25, y: h4 + 25)
        rightView!.layer.addSublayer(textLayer)
        
        session.addInput(AVCaptureDeviceInput(device: device, error: nil))
        session.addOutput(still)
        session.startRunning()
        
        videoLayer!.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        device!.lockForConfiguration(nil)
        device!.activeVideoMaxFrameDuration = CMTimeMake(1, fps)
        device!.activeVideoMinFrameDuration = CMTimeMake(1, fps)
        device!.unlockForConfiguration()
        videoConnection = still.connectionWithMediaType(AVMediaTypeVideo)
        videoConnection!.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        still.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1 / 30,
            target: self, selector: "renderLeft", userInfo: nil, repeats: true)
    }
    
    func renderLeft() {
        still.captureStillImageAsynchronouslyFromConnection(videoConnection!) {
            (buffer, error) -> Void in if buffer != nil {
                if self.over {
                    self.over = false
                    return
                }
                
                let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                let image = UIImage(data: data)
                let pos = self.hd.process(image)
                let x = pos[0] as! CGFloat + 10
                let y = pos[1] as! CGFloat + 10
                self.ball.center.x = x - 200
                self.ball.center.y = y - 200
                //println(x, y)
                
                let hcx = self.hoop.center.x
                let hcy = self.hoop.center.y
                let dist = sqrt(pow((x - hcx), 2) + pow((y - hcy), 2))
                
                println(dist)
                
                if dist < 250 {
                    self.score += 2
                    let s = (self.score as NSNumber).stringValue
                    self.textLayer!.string = s
                    //self.ball.center.x = 0
                    //self.ball.center.y = 0
                    self.over = true
                }

            }
        }

    }

}

