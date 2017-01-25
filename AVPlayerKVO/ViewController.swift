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
    var userPlayRate: Float = 1.0
    var userPlaying: Bool = false
    
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var positionSlider: UISlider!
    override func viewDidLoad() {
        super.viewDidLoad()

        loadAssetFromFile(urlString: "debussy.mp3")
        
//        if let url = URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8") {
//            let playerItem = AVPlayerItem(url: url)
//            
//            playerItem.addObserver(self, forKeyPath: "status", options: .new, context: &kvoContext)
//            
//            player = AVPlayer(playerItem: playerItem)
//            
//            let playerLayer = AVPlayerLayer(player: player)
//            //playerLayer.frame = self.videoContainer.bounds
//            self.videoContainer.layer.addSublayer(playerLayer)
//            
//            let timeInterval = CMTime(value: 1, timescale: 2)
//            player.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { (time: CMTime) in
//                print(time)
//                self.updatePositionSlider()
//            })
//        }
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
    
    func loadAssetFromFile(urlString: String) {
        guard let dot = urlString.range(of: ".") else { return }
        let fileParts = (resource: urlString.substring(to: dot.lowerBound), extension: urlString.substring(from: dot.upperBound))
        
        if let fileURL = Bundle.main.url(forResource: fileParts.resource, withExtension: fileParts.extension) {
            let asset = AVURLAsset(url: fileURL)
            let playerItem = AVPlayerItem(asset: asset)
            playerItem.addObserver(self, forKeyPath: "status", options: .new, context: &kvoContext)
            self.player = AVPlayer(playerItem: playerItem)
            
            let timeInterval = CMTime(value: 1, timescale: 2)
            player.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { (time: CMTime) in
                print(time)
                self.updatePositionSlider()
            })
        }
    }

    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &kvoContext {
            if keyPath == "status",
                let item = object as? AVPlayerItem {
                if item.status == .readyToPlay {
                    playPauseButton.isEnabled = true
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func positionSliderChanged(_ sender: UISlider) {
        guard let item = player.currentItem else { return }

        let newPosition = Double(sender.value) * item.duration.seconds
        
        player.seek(to: CMTime(seconds: newPosition, preferredTimescale: 1000))
        
        player.playImmediately(atRate: userPlayRate)
    }
    
    @IBAction func rateChange(_ sender: UISlider) {
        guard let item = player.currentItem else { return }
        
        userPlayRate = sender.value
        
        if item.canPlayFastForward {
            print("I can fast forward. Rate requested: \(sender.value).")
        }
        if item.canPlaySlowForward {
            print("I can slow forward")
        }
        
        if userPlaying {
            player.rate = userPlayRate
        }
        //print("NEW rate: \(player.rate).")

    }
    
    @IBAction func playPausePressed(_ sender: UIButton) {
        if !userPlaying {
            player.playImmediately(atRate: userPlayRate)
            sender.setTitle("Pause", for: .normal)
            //userPlaying = false
        }
        else {
            player.pause()
            sender.setTitle("Play", for: .normal)
            //userPlaying = true
        }
        userPlaying = !userPlaying
    }
}

