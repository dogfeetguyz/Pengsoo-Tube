//
//  MyVideo+CoreDataProperties.swift
//  
//
//  Created by Yejun Park on 25/3/20.
//
//

import Foundation
import CoreData


extension MyVideo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyVideo> {
        return NSFetchRequest<MyVideo>(entityName: "MyVideo")
    }

    @NSManaged public var channelTitle: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var thumbnailHigh: String?
    @NSManaged public var thumbnailMedium: String?
    @NSManaged public var thumbnailDefault: String?
    @NSManaged public var videoTitle: String?
    @NSManaged public var videoDescription: String?
    @NSManaged public var videoId: String?
    @NSManaged public var inPlaylist: Mylist?

}
