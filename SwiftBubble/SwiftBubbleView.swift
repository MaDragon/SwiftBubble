//
//  SwiftBubbleView.swift
//  SwiftBubble
//
//  Created by Felix Grabowski on 30/05/15.
//  Copyright (c) 2015 Felix Grabowski. All rights reserved.
//


import ScreenSaver
import AVFoundation
import AVKit


class SoapBubbleView: ScreenSaverView {
    
    var videoView:NSView!
    let frameRate = 29.97
    var player:AVPlayer!
    
    convenience init() {
        self.init(frame: CGRect.zero, isPreview: false)
    }
    
    static var layerClass: AnyClass {
		return AVPlayerLayer.self
	}
    
    override init!(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = 1.0 / frameRate
        
        guard let soapBubblePath = Bundle(for: type(of: self)).path(forResource: "SwiftBubble", ofType: "mov") else {
            fatalError("path to bubble not found")
        }
        
        let fileURL = URL(fileURLWithPath: soapBubblePath)
        let asset = AVAsset(url: fileURL)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        
        let videoView = NSView(frame: NSMakeRect(0, 0, NSWidth(frame)/2, NSHeight(frame)/2))
        videoView.wantsLayer = true

        centerView(videoView, inView: self)
        playerLayer.frame = videoView.frame
        videoView.layer = playerLayer
//        playerLayer.backgroundColor = NSColor.white.cgColor /// for debugging the view
        
        self.addSubview(videoView)
        
        //loop
        player.actionAtItemEnd = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func startAnimation() {
        player.play()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SoapBubbleView.restartVideo),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
        super.startAnimation()
    }
    
    override func stopAnimation() {
        NotificationCenter.default.removeObserver(self)
        super.stopAnimation()
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
    }
    
    override func animateOneFrame() {        
    }
    
    override func hasConfigureSheet() -> Bool {
        return false
    }
    
    override func configureSheet() -> NSWindow? {
        return nil
    }
    
    func restartVideo() {
        let seconds:Int64 = 0
        let preferredTimeScale:Int32 = 1
        let seekTime:CMTime = CMTimeMake(seconds, preferredTimeScale)
        player.seek(to: seekTime)
        player.play()
    }
    
    func centerView(_ v1:NSView, inView v2:NSView) {
        
        v1.translatesAutoresizingMaskIntoConstraints = false
        v2.translatesAutoresizingMaskIntoConstraints = false
        let multiplier:CGFloat = 0.75 // video scaling
        let equalWidth = NSLayoutConstraint(item: v1,
                                       attribute:NSLayoutAttribute.width,
                                       relatedBy:NSLayoutRelation.equal,
                                          toItem:self,
                                       attribute:NSLayoutAttribute.width,
                                      multiplier:multiplier,
                                        constant:0);
        let equalHeight = NSLayoutConstraint(item: v1,
                                        attribute:NSLayoutAttribute.height,
                                        relatedBy:NSLayoutRelation.equal,
                                           toItem:self,
                                        attribute:NSLayoutAttribute.height,
                                       multiplier:multiplier,
                                         constant:0);
        let centerX = NSLayoutConstraint(item: v1,
                                    attribute:NSLayoutAttribute.centerX,
                                    relatedBy:NSLayoutRelation.equal,
                                       toItem:self,
                                    attribute:NSLayoutAttribute.centerX,
                                   multiplier:1.0,
                                     constant:0);
        let centerY = NSLayoutConstraint(item: v1,
                                    attribute:NSLayoutAttribute.centerY,
                                    relatedBy:NSLayoutRelation.equal,
                                       toItem:self,
                                    attribute:NSLayoutAttribute.centerY,
                                   multiplier:1.0,
                                     constant:0);
        
        v2.addConstraint(equalWidth)
        v2.addConstraint(equalHeight)
        v2.addConstraint(centerX)
        v2.addConstraint(centerY)
    }
}
