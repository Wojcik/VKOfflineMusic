//
//  VMAudio.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK

class VMAudio: NSObject, NSCoding, Equatable {
    var id : NSNumber!
    var ownerID : NSNumber!
    var artist : NSString!
    var title : NSString!
    var URL : NSURL!
    var localURL : NSURL!
    var lyrics: VMLyrics!
    var albumID : NSNumber!
    var genreID : NSNumber!
    var duration : Int
    var durationString : NSString {
        get {
            let seconds = self.duration % 60
            let minutes = (self.duration % 3600) / 60
            if (self.duration > 3600) {
                let hours = self.duration / 3600
                return NSString(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                return NSString(format: "%d:%02d", minutes, seconds)
            }
        }
    }
    
    init(with audio: VKAudio) {
        self.id = audio.id
        self.ownerID = audio.owner_id
        self.artist = audio.artist
        self.title = audio.title
        if (audio.url != nil) {
            self.URL = NSURL.URLWithString(audio.url)
        }
        if (audio.lyrics_id != nil) {
            self.lyrics = VMLyrics(id: audio.lyrics_id)
        }
        self.albumID = audio.album_id
        self.genreID = audio.genre_id
        if (audio.duration != nil) {
            self.duration = audio.duration.integerValue
        } else {
            self.duration = 0
        }        
    }
    
    // MARK: - NSCoding interface implementation
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.id.integerValue, forKey: "id")
        aCoder.encodeInteger(self.ownerID.integerValue, forKey: "ownerID")
        aCoder.encodeObject(self.artist, forKey: "artist")
        aCoder.encodeObject(self.title, forKey: "title")
        aCoder.encodeObject(self.URL, forKey: "URL")
        aCoder.encodeObject(self.localURL, forKey: "localURL")
        aCoder.encodeObject(self.lyrics, forKey: "lyricsID")
        aCoder.encodeObject(self.albumID, forKey: "ownerID")
        aCoder.encodeInteger(self.duration, forKey: "duration")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.id = NSNumber(int: aDecoder.decodeIntForKey("id"))
        self.ownerID = NSNumber(int: aDecoder.decodeIntForKey("ownerID"))
        self.artist = aDecoder.decodeObjectForKey("artist") as NSString
        self.title = aDecoder.decodeObjectForKey("title") as NSString
        self.URL = aDecoder.decodeObjectForKey("URL") as NSURL
        self.localURL = aDecoder.decodeObjectForKey("localURL") as NSURL
        self.lyrics = aDecoder.decodeObjectForKey("lyricsID") as VMLyrics
        self.albumID = aDecoder.decodeObjectForKey("albumID") as NSNumber
        self.duration = NSNumber(int: aDecoder.decodeIntForKey("artist"))
    }
    
    // MARK: - Equatable
    
}

func ==(lhs: VMAudio, rhs: VMAudio) -> Bool {
    return lhs.id == rhs.id
}
