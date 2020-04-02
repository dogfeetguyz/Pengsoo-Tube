//
//  Video+CoreDataProperties.swift
//  
//
//  Created by Yejun Park on 2/4/20.
//
//

import Foundation
import CoreData


extension Video {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video")
    }

    @NSManaged public var publishedAt: String?
    @NSManaged public var thumbnailDefault: String?
    @NSManaged public var thumbnailHigh: String?
    @NSManaged public var thumbnailMedium: String?
    @NSManaged public var videoDescription: String?
    @NSManaged public var videoId: String?
    @NSManaged public var videoTitle: String?

}
