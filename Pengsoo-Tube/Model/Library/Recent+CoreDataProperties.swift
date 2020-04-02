//
//  Recent+CoreDataProperties.swift
//  
//
//  Created by Yejun Park on 2/4/20.
//
//

import Foundation
import CoreData


extension Recent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recent> {
        return NSFetchRequest<Recent>(entityName: "Recent")
    }


}
