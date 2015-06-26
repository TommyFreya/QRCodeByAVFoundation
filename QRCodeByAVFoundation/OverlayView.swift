//
//  OverlayView.swift
//  QRCodeByAVFoundation
//
//  Created by HMT on 15/5/21.
//  Copyright (c) 2015年 Tommy. All rights reserved.
//

import UIKit
import SnapKit

class OverlayView: UIView {
    
    var codeView: UIImageView!
    private var messageLabel: UILabel!
    var myCodeButton: UIButton!
    var scrollLabel: UIImageView!
    var clickCodeButtonClosure: dispatch_block_t?

    override init(frame: CGRect) {
        super.init(frame:frame)
        setUpCustomView()
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
    }
    
    private func setUpCustomView() {
        codeView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "pick_bg")
            self.addSubview(imageView)
            imageView.snp_makeConstraints{ (make) -> Void in
                make.top.equalTo(imageView.superview!.snp_top).offset(64+64)
                make.height.width.equalTo(280)
                make.centerX.equalTo(imageView.superview!.snp_centerX)
            }
            return imageView
            }()
        
        messageLabel = {
            let label = UILabel()
            label.text = "将二维码放入框内,即可自动扫描"
            label.textColor = UIColor.whiteColor()
            label.font = UIFont.systemFontOfSize(13.0)
            self.addSubview(label)
            label.snp_makeConstraints{ (make) -> Void in
                make.top.equalTo(self.codeView.snp_bottom).offset(10)
                make.centerX.equalTo(label.superview!.snp_centerX)
                make.height.equalTo(15)
            }
            return label
            }()
        
        scrollLabel = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "line")
            imageView.hidden = true
            self.addSubview(imageView)
            imageView.snp_makeConstraints{ (make) -> Void in
                make.width.equalTo(220)
                make.top.equalTo(self.codeView.snp_top)
                make.centerX.equalTo(imageView.superview!.snp_centerX)
                make.height.equalTo(5)
            }
            return imageView
            }()
        
        myCodeButton = {
            let button = UIButton.buttonWithType(.System) as! UIButton
            button.setTitle("我的二维码", forState: .Normal)
            button.setTitleColor(UIColor.greenColor(), forState: .Normal)
            button.addTarget(self, action: Selector("didClickCreateSelfCodeAction:"), forControlEvents: .TouchUpInside)
            self.addSubview(button)
            button.snp_makeConstraints{ (make) -> Void in
                make.top.equalTo(self.messageLabel.snp_bottom).offset(15)
                make.centerX.equalTo(button.superview!.snp_centerX)
                make.height.equalTo(30)
            }
            return button
            }()
    }
    
    func didClickCreateSelfCodeAction(btn: UIButton) {
        if let sureClosure = clickCodeButtonClosure {
            sureClosure()
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}













