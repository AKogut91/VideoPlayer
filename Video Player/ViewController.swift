//
//  ViewController.swift
//  Video Player
//
//  Created by Alex Kogut on 08.02.2022.
//

import UIKit
import AVFoundation

final class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var playerView: PlayerView!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var startTimeLabel: UILabel!
    @IBOutlet private weak var timeSlider: UISlider!
    
     // MARK: - Properties
    private let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()

    private let videoURL =  "http://www.exit109.com/~dnn/clips/RW20seconds_2.mp4" //"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    
    // MARK: - Life Cycler
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setPlayer()
        playVideo()
    }

    // MARK: - Private Method
    private func setPlayer() {
        playerView.backgroundColor = .clear
        playerView.delegate = self
    }
    
    // MARK: - Internal Methods
    func setupUI() {
        startTimeLabel.text = "00:00"
        durationLabel.text = "00:00"
        timeSlider.value = 0.0
    }
    
    func playVideo() {
        guard let url = URL(string: videoURL) else { return }
        playerView.play(with: url)
    }
    
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
    
    // MARK: - IBActions
    @IBAction func playPauseAction(_ sender: UIButton) {
        playerView.playerAction()
    }
    
    @IBAction func timeSliderDidChange(_ sender: UISlider) {
        let newTime = CMTime(seconds: Double(sender.value), preferredTimescale: 600)
        playerView.set(newTime: newTime)
    }
    
    @IBAction func seekForward(_ sender: Any) {
        playerView.seekBackwardForward(type: .forward)
    }

    @IBAction func seekBackward(_ sender: Any) {
        playerView.seekBackwardForward(type: .backward)
    }
}

// MARK: - PlayerViewDelegate
extension ViewController: PlayerViewDelegate {
    
    func sliderMaximum(value: Float) {
        timeSlider.maximumValue = value
    }
    
    func timeElapsed(seconds: Float, sliderValue: Float) {
        timeSlider.value = sliderValue
        startTimeLabel.text = createTimeString(time: seconds)
    }
    
    func duration(seconds: Float) {
        durationLabel.text = createTimeString(time: seconds)
    }
    
    func playPauseAction(state: PlayerViewButtonState) {
        switch state {
        case .play:
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        case .pause:
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
}
