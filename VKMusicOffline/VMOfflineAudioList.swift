//
//  VMAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 24.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation

class VMOfflineAudioList: VMAudioList, NSCoding {
    
    var identifier: NSUUID
    
    init(title: NSString) {
        self.identifier = NSUUID.UUID()
        super.init()
        self.title = title
    }
    
    func addAudio(audio:VMAudio) {
        self.audios = self.audios.arrayByAddingObject(audio)
    }
    
    // MARK: - NSCoding interface implementation
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.identifier, forKey:"identifier")
        aCoder.encodeObject(self.title, forKey:"title")
        aCoder.encodeObject(self.audios, forKey:"audios")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.identifier = aDecoder.decodeObjectForKey("identifier") as NSUUID
        super.init()
        self.title = aDecoder.decodeObjectForKey("title") as NSString
        self.audios = aDecoder.decodeObjectForKey("audios") as NSArray
    }

    // MARK: - VMAudio overrides
    
    override var searchResultsList: VMAudioList? {
        get {
            return VMOfflineAudioSearchList(offlineAudioList: self)
        }
    }
    
    override var totalCount: Int {
        get {
            return self.audios.count
        }
        set {
            assert(false, "Cannot set total count for offline audio list")
        }
    }
}
