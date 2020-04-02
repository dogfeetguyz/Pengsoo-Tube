//
//  PlaylistModel.swift
//  Pengsoo-Tube
//
//  Created by Yejun Park on 2/4/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

import Foundation

struct PlaylistModel {
    var title: String = ""
    var videos: [VideoItemModel] = []
    
    init(title: String, videos: [PlaylistVideo]) {
        self.title = title
        self.videos = videos.map() {
            return VideoItemModel(videoId: $0.videoId!, videoTitle: $0.videoTitle!, videoDescription: $0.videoDescription!, thumbnailDefault: $0.thumbnailDefault!, thumbnailMedium: $0.thumbnailMedium!, thumbnailHigh: $0.thumbnailHigh!, publishedAt: $0.publishedAt!)
        }
    }
}

extension PlaylistModel: Equatable {
    static func == (lhs: PlaylistModel, rhs: PlaylistModel) -> Bool {
        return lhs.title == rhs.title
    }
}
