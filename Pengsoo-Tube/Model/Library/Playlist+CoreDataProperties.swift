//
//  Playlist+CoreDataProperties.swift
//  
//
//  Created by Yejun Park on 2/4/20.
//
//

import Foundation
import CoreData


extension Playlist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Playlist> {
        return NSFetchRequest<Playlist>(entityName: "Playlist")
    }

    @NSManaged public var title: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var playlistVideos: NSOrderedSet?

}

// MARK: Generated accessors for playlistVideos
extension Playlist {

    @objc(insertObject:inPlaylistVideosAtIndex:)
    @NSManaged public func insertIntoPlaylistVideos(_ value: PlaylistVideo, at idx: Int)

    @objc(removeObjectFromPlaylistVideosAtIndex:)
    @NSManaged public func removeFromPlaylistVideos(at idx: Int)

    @objc(insertPlaylistVideos:atIndexes:)
    @NSManaged public func insertIntoPlaylistVideos(_ values: [PlaylistVideo], at indexes: NSIndexSet)

    @objc(removePlaylistVideosAtIndexes:)
    @NSManaged public func removeFromPlaylistVideos(at indexes: NSIndexSet)

    @objc(replaceObjectInPlaylistVideosAtIndex:withObject:)
    @NSManaged public func replacePlaylistVideos(at idx: Int, with value: PlaylistVideo)

    @objc(replacePlaylistVideosAtIndexes:withPlaylistVideos:)
    @NSManaged public func replacePlaylistVideos(at indexes: NSIndexSet, with values: [PlaylistVideo])

    @objc(addPlaylistVideosObject:)
    @NSManaged public func addToPlaylistVideos(_ value: PlaylistVideo)

    @objc(removePlaylistVideosObject:)
    @NSManaged public func removeFromPlaylistVideos(_ value: PlaylistVideo)

    @objc(addPlaylistVideos:)
    @NSManaged public func addToPlaylistVideos(_ values: NSOrderedSet)

    @objc(removePlaylistVideos:)
    @NSManaged public func removeFromPlaylistVideos(_ values: NSOrderedSet)

}
