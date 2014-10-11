//
//  VMAudioListPlayer.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 30.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import AVFoundation

class VMAudioListPlayer: NSObject {
    
    // MARK: - Singleton
    class var sharedInstance : VMAudioListPlayer {
    struct Static {
        static var onceToken : dispatch_once_t = 0
        static var instance : VMAudioListPlayer? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = VMAudioListPlayer()
        }
        return Static.instance!
    }
    
    // MARK: - Instance variables
    var audioList: VMAudioList!
    
    private var player: AVPlayer!

    // MARK: - State
    
    var isPlaying: Bool {
        get {
            return self._isPlaying
        }
    }
    
    var playbackProgress : CMTime {
        get {
            return self._playbackProgress
        }
    }
    
    var volume: Float = 1.0 {
        willSet {
            self.willChangeValueForKey("volume")
            self.player.volume = newValue
        }
        didSet {
            self.didChangeValueForKey("volume")
        }
    }
    
    enum ShufflingMode {
        case NoShuffling
        case RandomShufling
    }
    
    var shufflingMode: ShufflingMode = ShufflingMode.NoShuffling{
        willSet {
            self.willChangeValueForKey("shufflingMode")
        }
        didSet {
            self.didChangeValueForKey("shufflingMode")
        }
    }
    
    var loadedTrackPartTimeRange: CMTimeRange {
        get {
            return self._loadedTrackPartTimeRange
        }
    }
    
    enum State {
        case Idle
        case ReadyToPlay
        case Failed(error: NSError!)
    }
    
    var state: State {
        get {
            return self._state
        }
    }
    
    // MARK: - Player interface
    
    func play() {
        NSLog("VMAudioListPlayer play")
        self.player.play()
        self._isPlaying = true
    }
    
    func pause() {
        NSLog("VMAudioListPlayer pause")
        self.player.pause()
        self._isPlaying = false
    }
    
    func seekToTime(time:CMTime) {
        if (self.player.status == AVPlayerStatus.ReadyToPlay) {
            if (self.isPlaying) {
                self.player.pause()
            }
            self.player.currentItem.cancelPendingSeeks()
            self.player.currentItem.seekToTime(time, completionHandler: { (finished: Bool) -> Void in
                if (self.isPlaying) {
                    self.player.play()
                }
            })
        }
    }
    
    var currentTrack: VMAudio! {
        get {
            return self.audioList[self.currentTrackIndex]
        }
    }
    
    var currentTrackIndex: Int = 0 {
        didSet {
            var playerItem: AVPlayerItem! = nil
            if (self.currentTrack.localURL != nil) {
                playerItem = AVPlayerItem(URL: self.currentTrack.localURL)
            } else {
                playerItem = AVPlayerItem(URL: self.currentTrack.URL)
            }
            playerItem.addObserver(self, forKeyPath: "status", options: nil, context: nil)
            self.player = AVPlayer(playerItem: playerItem)
            self.player.actionAtItemEnd = AVPlayerActionAtItemEnd.Pause
        }
    }
    
    // MARK: - Privates
    
    private var _isPlaying: Bool = false {
        willSet {
            self.willChangeValueForKey("isPlaying")
        }
        didSet {
            self.didChangeValueForKey("isPlaying")
        }
    }
    
    private var _state: State = State.Idle {
        willSet {
            self.willChangeValueForKey("state")
        }
        didSet {
            self.didChangeValueForKey("state")
        }
    }
    
    private var _loadedTrackPartTimeRange: CMTimeRange = kCMTimeRangeZero {
        willSet {
            self.willChangeValueForKey("loadedTrackPartTimeRange")
        }
        didSet {
            self.didChangeValueForKey("loadedTrackPartTimeRange")
        }
    }
    
    private var _playbackProgress: CMTime = kCMTimeZero {
        willSet {
            self.willChangeValueForKey("playbackProgress")
        }
        didSet {
            self.didChangeValueForKey("playbackProgress")
        }
    }
    
    private func timeRangeFrom(timeRanges: NSArray) -> CMTimeRange {
        var loadedTrackPartTimeRange = kCMTimeRangeZero
        // TODO: Fix logic to more correct
        for value in timeRanges {
            let timeRange = (value as NSValue).CMTimeRangeValue
            if (CMTimeGetSeconds(timeRange.duration) >
                CMTimeGetSeconds(loadedTrackPartTimeRange.duration)) {
                loadedTrackPartTimeRange = timeRange
            }
        }
        return loadedTrackPartTimeRange
    }
    
    private var playbackObserver: AnyObject!
    
    override init() {
        
    }
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
        if object is AVPlayerItem {
            let playerItem = object as AVPlayerItem
            if keyPath == "status" {
                switch playerItem.status {
                case AVPlayerItemStatus.ReadyToPlay:
                    NSLog("VMAudioListPlayer: AVPlayerItem ready to play")
                    
                    let timeInterval = CMTimeMakeWithSeconds(0.1, 600)
                    self.playbackObserver = self.player.addPeriodicTimeObserverForInterval(timeInterval, queue: dispatch_get_main_queue(), usingBlock: { (time: CMTime) -> Void in
                        self._playbackProgress = self.player.currentItem.currentTime()
                        self._loadedTrackPartTimeRange = self.timeRangeFrom(self.player.currentItem.loadedTimeRanges)
                        NSLog("loaded part of track: from \(CMTimeGetSeconds(self._loadedTrackPartTimeRange.start)), duration \(CMTimeGetSeconds(self._loadedTrackPartTimeRange.duration)) seconds")
                    })
                case AVPlayerItemStatus.Failed:
                    NSLog("VMAudioListPlayer: AVPlayerItem: Failed with error \(playerItem.error)")
                    self._state = State.Failed(error: playerItem.error)
                case AVPlayerItemStatus.Unknown:
                    NSLog("VMAudioListPlayer: AVPlayerItem: Unknown status, eror \(playerItem.error)")
                    self._state = State.Failed(error: nil)
                }
            }
        }
    }
}
