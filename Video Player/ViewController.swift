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
        timeSlider.isContinuous = true
    }
    
    func playVideo() {
        guard let url = URL(string: videoURL) else { return }
        playerView.play(with: url)
    }
    
    func createTimeString(time: Float) -> String {
        var components = DateComponents()
        components.second = Int(max(0.0, time))
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: components) ?? ""
    }
    
    // MARK: - IBActions
    @IBAction func playPauseAction(_ sender: UIButton) {
        playerView.playerAction()
    }
    
    @IBAction func timeSliderDidChange(_ sender: UISlider) {
//        Как выбрать разумный timescale, чтобы не получить обрезанный кусок? Apple рекомендует 600 для видео (объясняя это тем, что 600 универсален для большинства видео с частотой 24, 25 и 30 кадров в секунду). //https://habr.com/ru/post/173897/
        
        let newTime = CMTime(seconds: Double(sender.value), preferredTimescale: 600)
        playerView.set(newTime: newTime)
    }
    
    @IBAction func seekForward(_ sender: Any) {
        playerView.seekBackwardForward(type: .forward, seconds: 5)
    }

    @IBAction func seekBackward(_ sender: Any) {
        playerView.seekBackwardForward(type: .backward, seconds: 5)
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
        case .stop:
            playPauseButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        }
    }
}
