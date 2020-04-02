//
//  PlayModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 31/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation

struct VideoItemModel {
    var videoId: String = ""
    var videoTitle: String = ""
    var videoDescription: String = ""
    var thumbnailDefault: String = ""
    var thumbnailMedium: String = ""
    var thumbnailHigh: String = ""
    var publishedAt: String = ""
    
    init(videoId: String, videoTitle: String, videoDescription: String, thumbnailDefault: String, thumbnailMedium: String, thumbnailHigh: String, publishedAt: String) {
        self.videoId = videoId
        self.videoTitle = videoTitle
        self.videoDescription = videoDescription
        self.thumbnailDefault = thumbnailDefault
        self.thumbnailMedium = thumbnailMedium
        self.thumbnailHigh = thumbnailHigh
        self.publishedAt = publishedAt
    }
}

extension VideoItemModel: Equatable {
    static func == (lhs: VideoItemModel, rhs: VideoItemModel) -> Bool {
        return lhs.videoId == rhs.videoId
    }
}
