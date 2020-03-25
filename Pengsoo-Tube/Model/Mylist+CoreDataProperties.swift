//
//  Mylist+CoreDataProperties.swift
//  
//
//  Created by Yejun Park on 25/3/20.
//
//

import Foundation
import CoreData


extension Mylist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mylist> {
        return NSFetchRequest<Mylist>(entityName: "Mylist")
    }

    @NSManaged public var updatedAt: Date?
    @NSManaged public var title: String?
    @NSManaged public var videos: NSOrderedSet?

}

// MARK: Generated accessors for videos
extension Mylist {

    @objc(insertObject:inVideosAtIndex:)
    @NSManaged public func insertIntoVideos(_ value: MyVideo, at idx: Int)

    @objc(removeObjectFromVideosAtIndex:)
    @NSManaged public func removeFromVideos(at idx: Int)

    @objc(insertVideos:atIndexes:)
    @NSManaged public func insertIntoVideos(_ values: [MyVideo], at indexes: NSIndexSet)

    @objc(removeVideosAtIndexes:)
    @NSManaged public func removeFromVideos(at indexes: NSIndexSet)

    @objc(replaceObjectInVideosAtIndex:withObject:)
    @NSManaged public func replaceVideos(at idx: Int, with value: MyVideo)

    @objc(replaceVideosAtIndexes:withVideos:)
    @NSManaged public func replaceVideos(at indexes: NSIndexSet, with values: [MyVideo])

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: MyVideo)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: MyVideo)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSOrderedSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSOrderedSet)

}
