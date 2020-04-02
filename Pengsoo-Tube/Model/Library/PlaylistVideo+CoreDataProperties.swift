//
//  PlaylistVideo+CoreDataProperties.swift
//  
//
//  Created by Yejun Park on 2/4/20.
//
//

import Foundation
import CoreData


extension PlaylistVideo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaylistVideo> {
        return NSFetchRequest<PlaylistVideo>(entityName: "PlaylistVideo")
    }

    @NSManaged public var inPlaylist: Playlist?

}
