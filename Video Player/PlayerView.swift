//
//  PlayerView.swift
//  Video Player
//
//  Created by Alex Kogut on 08.02.2022.
//

import UIKit
import AVFoundation

enum PlayerViewButtonState {
    case play
    case pause
    case stop
}

enum PlayerButtonType {
    case backward
    case forward
}

protocol PlayerViewDelegate: AnyObject {
    func playPauseAction(state: PlayerViewButtonState)
    func duration(seconds: Float)
    func timeElapsed(seconds: Float, sliderValue: Float)
    func sliderMaximum(value: Float)
}

final class PlayerView: UIView {
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var delegate: PlayerViewDelegate?
    
    private var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    private var state: PlayerViewButtonState = .pause {
        didSet {
            delegate?.playPauseAction(state: state)
        }
    }
    
    private var timeObserverToken: Any?
    private var playerItemContext = 0
    private var playerItem: AVPlayerItem?
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // Switch over status value
            switch status {
            case .readyToPlay:
                print(".readyToPlay")
                player?.play()
                state = .play
                delegate?.sliderMaximum(value: Float(player?.currentItem?.duration.seconds ?? 0.0))
                
            case .failed:
                print(".failed")
            case .unknown:
                print(".unknown")
            @unknown default:
                print("@unknown default")
            }
        }
    }
    
    // MARK: - Private Method
    private func setUpAsset(with url: URL, completion: ((_ asset: AVAsset) -> Void)?) {
        let asset = AVAsset(url: url)
        getDurationVideo(asset: asset)
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                completion?(asset)
            case .failed:
                print(".failed")
            case .cancelled:
                print(".cancelled")
            default:
                print("default")
            }
        }
    }
    
    private func setUpPlayerItem(with asset: AVAsset) {
        playerItem = AVPlayerItem(asset: asset)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
        
        DispatchQueue.main.async {
            self.player = AVPlayer(playerItem: self.playerItem)
            self.setupTimeObserver()
            self.setupPlayerDidFinishPlayingObserver()
        }
    }
    
    private func getDurationVideo(asset: AVAsset) {
        let asset = asset.duration
        let duration = CMTimeGetSeconds(asset)
        delegate?.duration(seconds: Float(duration))
    }
    
    /*
     Create a periodic observer to update the movie player time slider
     during playback.
     */
    private func setupTimeObserver() {
        let interval = CMTime(value: 1, timescale: 2)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [unowned self] time in
            let timeElapsed = Float(time.seconds)
            let currentTime = Float(CMTimeGetSeconds(player?.currentTime() ?? CMTime.init()))
            delegate?.timeElapsed(seconds: timeElapsed, sliderValue: currentTime)
        }
    }
    
    /*
     Create a  observer to check the movie player is Finish Playing
     */
    private func setupPlayerDidFinishPlayingObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(self.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: self.player?.currentItem)
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        state = .stop
        repeatPlayer()
    }
    
    // MARK: - Internal Methods
    func play(with url: URL) {
        setUpAsset(with: url) { [weak self] (asset: AVAsset) in
            self?.setUpPlayerItem(with: asset)
        }
    }
    
    func playerAction() {
        switch state {
        case .play:
            player?.pause()
            state = .pause
        case .pause,  .stop:
            player?.play()
            state = .play
        }
    }
    
    func set(newTime: CMTime) {
        player?.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func seekBackwardForward(type: PlayerButtonType, seconds: Double) {
        guard let currentPlayer  = player else {
            return
        }
        
        let playerCurrentTime = CMTimeGetSeconds(currentPlayer.currentTime())
        var newTime: Double
        
        switch type {
        case .backward:
            newTime = playerCurrentTime - seconds
            
            if newTime < 0 {
                newTime = 0
            }
            
        case .forward:
            newTime = playerCurrentTime + 5
        }
        
        let updatedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player?.seek(to: updatedTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    func repeatPlayer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.player?.seek(to: CMTime.zero)
            self.player?.play()
            self.state = .play
        }
    }
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        print("deinit of PlayerView")
    }
}
