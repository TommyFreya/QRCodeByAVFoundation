//
//  QRCodeViewController.swift
//  QRCodeByAVFoundation
//
//  Created by HMT on 15/5/21.
//  Copyright (c) 2015年 Tommy. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

struct ScreenWH {
    static let screenWidth = UIScreen.mainScreen().bounds.size.width
    static let screenHeight = UIScreen.mainScreen().bounds.size.height
}

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureView: UIView!
    var qrcodeView: OverlayView!
    var timer: NSTimer?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 消除导航栏返回自带的数字
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Default)
        
        initCapture()
        setupCaptureView()
        if let goodSession = captureSession {
            // 启动
            goodSession.startRunning()
            timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("scrollScanAction"), userInfo: nil, repeats: true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if let sureTimer = timer {
            sureTimer.invalidate()
        }
    }
    
    // MARK: - View Setup
    private func setupCaptureView() {
        // 创建系统自动捕获框
        captureView = {
            let captureView = UIView()
            captureView.layer.borderColor = UIColor.greenColor().CGColor
            captureView.layer.borderWidth = 2
            self.view.addSubview(captureView)
            self.view.bringSubviewToFront(captureView)
            return captureView
            }()
        // 扫一扫的图片
        qrcodeView = {
            let codeView = OverlayView(frame: CGRectZero)
            codeView.clickCodeButtonClosure = {
                let myCodeVC = self.storyboard!.instantiateViewControllerWithIdentifier("MyCodeViewController") as! MyCodeViewController
                self.navigationController!.pushViewController(myCodeVC, animated: true)
            }
            self.view.addSubview(codeView)
            self.view.bringSubviewToFront(self.captureView)
            codeView.snp_makeConstraints{ (make) -> Void in
                make.edges.equalTo(self.view)
            }
            return codeView
            }()
    }
    
    // MARK: - Private Methods
    // 初始化视频捕获
    private func initCapture() {
        // 代表抽象的硬件设备,这里传入video
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error: NSError?
        // 输入流
        var captureInput = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error) as? AVCaptureDeviceInput
        if (error != nil && captureInput == nil) {
            let errorAlert = UIAlertController(title: "提醒", message: "请在iPhone的\"设置-隐私-相机\"选项中,允许XXX访问您的相机", preferredStyle: .Alert)
            errorAlert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(errorAlert, animated: true, completion: nil)
        } else {
            // input和output的桥梁,它协调着intput到output的数据传输.(见字意,session-会话)
            captureSession = AVCaptureSession()
            captureSession!.addInput(captureInput)
            
            // 输出流
            let captureMetadataOutput = AVCaptureMetadataOutput()
            // 限制扫描区域http://blog.csdn.net/lc_obj/article/details/41549469
            captureMetadataOutput.rectOfInterest = CGRectMake(128.0/ScreenWH.screenHeight, (ScreenWH.screenWidth - 280.0)/ScreenWH.screenWidth * 2.0, 280.0/ScreenWH.screenHeight, 280.0/ScreenWH.screenWidth)
            captureSession!.addOutput(captureMetadataOutput)
            // 添加的队列按规定必须是串行
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            // 指定信息类型,QRCode,你懂的
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            // 用这个预览图层和图像信息捕获会话(session)来显示视频
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer!.frame = view.bounds
            view.layer.addSublayer(videoPreviewLayer!)
        }
    }
    // 关闭捕获
    private func stopCapture() {
        captureSession!.startRunning()
        captureView.removeFromSuperview()
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            captureView!.frame = CGRectZero
            return
        }
        // 刷取出来的数据
        for metadataObject in metadataObjects {
            if metadataObject.type == AVMetadataObjectTypeQRCode {
                let metadata = metadataObject as! AVMetadataMachineReadableCodeObject
                // 元数据对象就会被转化成图层的坐标
                let codeCoord = videoPreviewLayer!.transformedMetadataObjectForMetadataObject(metadata) as! AVMetadataMachineReadableCodeObject
                captureView!.frame = codeCoord.bounds
                if metadata.stringValue != nil {
                    println("\(metadata.stringValue)")
                    self.captureSession!.stopRunning()
                    let successAlert = UIAlertController(title:"提示", message:"是否打开" + metadata.stringValue, preferredStyle: .Alert)
                    successAlert.addAction(UIAlertAction(title:"取消", style: .Default, handler: { (_) -> Void in
                        self.stopCapture()
                    }))
                    successAlert.addAction(UIAlertAction(title:"确定", style: .Default, handler: { (_) -> Void in
                        if metadata.stringValue.lowercaseString.hasPrefix("http") {
                            UIApplication.sharedApplication().openURL(NSURL(string: metadata.stringValue)!)
                            self.navigationController!.popViewControllerAnimated(true)
                        }
                    }))
                    self.presentViewController(successAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Event Actions
    // 定时器控制扫描控件
    func scrollScanAction() {
        qrcodeView.scrollLabel.hidden = false
        qrcodeView.scrollLabel.snp_updateConstraints { (make) -> Void in
            // error,因为supdate只能更新原有约束的值,并不能加入新的约束
            // make.bottom.equalTo(self.qrcodeView.codeView.snp_bottom).offset(-10)
            make.top.equalTo(self.qrcodeView.codeView.snp_top).offset(270)
        }
        UIView.animateWithDuration(1.9, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (_) -> Void in
            self.qrcodeView.scrollLabel.snp_updateConstraints { (make) -> Void in
                make.top.equalTo(self.qrcodeView.codeView.snp_top).offset(5)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//.....
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


















