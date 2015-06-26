//
//  MyCodeViewController.swift
//  QRCodeByAVFoundation
//
//  Created by HMT on 15/6/1.
//  Copyright (c) 2015年 Tommy. All rights reserved.
//

import UIKit

class MyCodeViewController: UIViewController {
    
    @IBOutlet weak var textStrTextField: UITextField!
    @IBOutlet weak var imageNameTextField: UITextField!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Event Action
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    @IBAction func clickCreateQrCodeAction(sender: UIButton) {
        qrCodeImageView.image = createQRForString(textStrTextField.text, qrImageName: imageNameTextField.text)
    }
    
    // MARK: - Private Methods
    private func createQRForString(qrString: String?, qrImageName: String?) -> UIImage?{
        if let sureQRString = qrString {
            let stringData = sureQRString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            // 创建一个二维码的滤镜
            let qrFilter = CIFilter(name: "CIQRCodeGenerator")
            qrFilter.setValue(stringData, forKey: "inputMessage")
            qrFilter.setValue("H", forKey: "inputCorrectionLevel")
            let qrCIImage = qrFilter.outputImage
            // 创建一个颜色滤镜,黑白色
            let colorFilter = CIFilter(name: "CIFalseColor")
            colorFilter.setDefaults()
            colorFilter.setValue(qrCIImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
            colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
            // 返回二维码image
            let codeImage = UIImage(CIImage: colorFilter.outputImage.imageByApplyingTransform(CGAffineTransformMakeScale(5, 5)))
            // 通常,二维码都是定制的,中间都会放想要表达意思的图片
            if let iconImage = UIImage(named: qrImageName!) {
                let rect = CGRectMake(0, 0, codeImage!.size.width, codeImage!.size.height)
                UIGraphicsBeginImageContext(rect.size)
                
                codeImage!.drawInRect(rect)
                let avatarSize = CGSizeMake(rect.size.width * 0.25, rect.size.height * 0.25)
                let x = (rect.width - avatarSize.width) * 0.5
                let y = (rect.height - avatarSize.height) * 0.5
                iconImage.drawInRect(CGRectMake(x, y, avatarSize.width, avatarSize.height))
                let resultImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                return resultImage
            }
            return codeImage
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
































