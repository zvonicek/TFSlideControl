//
//  TFSlideControl.swift
//  Pods
//
//  Created by Jakub Knejzlik on 07/10/15.
//
//

import UIKit

@IBDesignable public class TFSlideControl: UIControl {
    
    public var sliderStrategy: TFSlideControlSliderStrategyProtocol = TFSlideControlSliderDefaultStrategy()
    public var resetAfterValueChange: Bool = false
    
    
    private var trackingTouch: UITouch?
    
    
    @IBInspectable public var backgroundImage: UIImage? {
        get{
            if let imageView = backgroundView as? UIImageView {
                return imageView.image
            } else {
                return nil
            }
        }
        set(image){
            let imageView = UIImageView.init()
            imageView.contentMode = .ScaleToFill
            imageView.image = image
            backgroundView = imageView
        }
    }
    @IBInspectable public var overlayImage: UIImage? {
        get{
            if let imageView = overlayView as? UIImageView {
                return imageView.image
            } else {
                return nil
            }
        }
        set(image){
            let imageView = UIImageView.init()
            imageView.contentMode = .ScaleToFill
            imageView.image = image
            overlayView = imageView
        }
    }
    @IBInspectable public var maskImage: UIImage? {
        didSet{
            layer.mask = CALayer.init()
            if let maskLayer = self.layer.mask, maskImage = maskImage {
                maskLayer.contents = maskImage.CGImage
            }
        }
    }
    
    
    public var backgroundView: UIView? {
        willSet{
            if let backgroundView = backgroundView {
                backgroundView.removeFromSuperview()
            }
        }
        didSet{
            if let backgroundView = backgroundView {
                self.addSubview(backgroundView)
                self.sendSubviewToBack(backgroundView)
            }
        }
    }
    public var overlayView: UIView? {
        willSet{
            if let overlayView = overlayView {
                overlayView.removeFromSuperview()
            }
        }
        didSet{
            if let overlayView = overlayView {
                self.addSubview(overlayView)
                self.bringSubviewToFront(overlayView)
            }
        }
    }
    
    
    public var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    {
        willSet{
            handleView.removeFromSuperview()
        }
        didSet{
            if let overlayView = overlayView {
                self.insertSubview(handleView, belowSubview: overlayView)
            } else {
                self.addSubview(handleView)
            }
        }
    }
    
    

    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    private func customInit() {
        addSubview(handleView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let overlayView = overlayView {
            overlayView.frame = self.bounds
        }
        if let backgroundView = backgroundView {
            backgroundView.frame = self.bounds
        }
        if let maskLayer = self.layer.mask {
            maskLayer.frame = self.bounds
        }
    }
    

    public func reset(animated: Bool) {
        sliderStrategy.updateSlideToInitialPosition(self, animated: animated)
    }
    
    
    public override func prepareForInterfaceBuilder() {
        handleView.frame = CGRectMake(0, 0, bounds.size.width/2.0, bounds.size.height)
//        backgroundColor = UIColor.redColor()
    }
    
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if sliderStrategy.isTouchValidForBegin(self, touch: touch) && (trackingTouch == nil) {
                startDragging(touch)
                break
            }
        }
    }
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        updateDragging()
    }
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if trackingTouch != nil && touches.contains(trackingTouch!){
            if sliderStrategy.isTouchValidForFinish(self, touch: trackingTouch!){
                endDragging()
            } else {
                cancelDragging()
            }
        }
    }
    
    
    
    private func updateSlideControlForTrackingTouch() {
        if let trackingTouch = trackingTouch {
            sliderStrategy.updateSlideControlForTouch(self, touch: trackingTouch)
        }
    }
    
    private func startDragging(touch: UITouch) {
        trackingTouch = touch
        reset(false)
    }
    private func updateDragging() {
        updateSlideControlForTrackingTouch()
    }
    private func cancelDragging() {
        trackingTouch = nil
        reset(true)
    }
    private func endDragging() {
        updateSlideControlForTrackingTouch()
        trackingTouch = nil
        sendActionsForControlEvents(.ValueChanged)
        if resetAfterValueChange {
            reset(true)
        }
    }
}