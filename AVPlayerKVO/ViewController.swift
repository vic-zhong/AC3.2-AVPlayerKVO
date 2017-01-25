//
//  ViewController.swift
//  AVPlayerKVO
//
//  Created by Jason Gresh on 1/25/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import AVFoundation

private var kvoContext = 0

class ViewController: UIViewController {
    var player: AVPlayer!
    
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var positionSlider: UISlider!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8") {
            let playerItem = AVPlayerItem(url: url)
            
            playerItem.addObserver(self, forKeyPath: "status", options: .new, context: &kvoContext)
            
            player = AVPlayer(playerItem: playerItem)
            
            let playerLayer = AVPlayerLayer(player: player)
            //playerLayer.frame = self.videoContainer.bounds
            self.videoContainer.layer.addSublayer(playerLayer)
            
            let timeInterval = CMTime(value: 1, timescale: 2)
            player.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { (time: CMTime) in
                print(time)
                self.updatePositionSlider()
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        guard let sublayers = self.videoContainer.layer.sublayers
            else {
                return
        }
        
        for layer in sublayers {
            layer.frame = self.videoContainer.bounds
        }
    }
    
    // MARK: - Utility
    func updatePositionSlider() {
        guard let item = player.currentItem else { return }
        
        let currentPlace = Float(item.currentTime().seconds / item.duration.seconds)
        self.positionSlider.value = currentPlace
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &kvoContext {
            if keyPath == "status",
                let item = object as? AVPlayerItem {
                if item.status == .readyToPlay {
                    player.play()
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func positionSliderChanged(_ sender: UISlider) {
        guard let item = player.currentItem else { return }

        let newPosition = Double(sender.value) * item.duration.seconds
        
        player.seek(to: CMTime(seconds: newPosition, preferredTimescale: 1000))
    }
}

