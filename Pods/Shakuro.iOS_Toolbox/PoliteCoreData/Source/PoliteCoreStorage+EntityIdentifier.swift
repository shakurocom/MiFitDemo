//
// Copyright (c) 2019 Shakuro (https://shakuro.com/)
//
//

import CoreData
import Foundation

public extension NSPredicate {

    enum Constant {
        public static let defaultIdKey = "identifier"
    }

    /// Helper method for building predicates based on entity identifier, and additional predicate if needed
    ///
    /// - Parameters:
    ///   - identifier: The identifier of entity, an object that adopts [PredicateConvertible](x-source-tag://PredicateConvertible)
    ///   - identifierKey: The String key used to construct correct NSPredicate
    ///   - format: The format string for additional predicate
    ///   - argumentArray: The arguments for additional predicate
    /// - Returns: The compound predicate "(identifierKey = identifier) AND (additional predicate format)"
    /// - Tag: objectWithIDPredicate
    class func objectWithIDPredicate(_ identifier: PredicateConvertible,
                                     identifierKey: String = Constant.defaultIdKey,
                                     andPredicateFormat format: String? = nil,
                                     argumentArray: [Any]? = nil) -> NSPredicate {
        var rootPredicate = NSPredicate(format: "\(identifierKey) = \(identifier.getPredicateFormat())", identifier.getPredicateValue())
        if let andPredicateFormat = format {
            rootPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [rootPredicate, NSPredicate(format: andPredicateFormat, argumentArray: argumentArray)])
        }
        return rootPredicate
    }

}

public extension PoliteCoreStorage {

    /// Finds first entity that matches identifier and additional predicate, or creates new one if no entity found
    /// See also: [findFirstOrCreate](x-source-tag://findFirstOrCreate)
    ///
    /// - Parameters:
    ///   - entityType: A type of entity to find
    ///   - identifier: The identifier of entity, an object that adopts [PredicateConvertible](x-source-tag://PredicateConvertible)
    ///   - identifierKey: The String key used to construct correct NSPredicate
    ///   - context: NSManagedObjectContext where entity should be find
    ///   - format: Format for additional predicate. See [objectWithIDPredicate](x-source-tag://PredicateConvertible)
    ///   - argumentArray: Array of arguments for additional predicate. See [objectWithIDPredicate](x-source-tag://PredicateConvertible)
    /// - Returns: First found or created entity, never returns nil
    /// - Tag: findFirstByIdOrCreate
    func findFirstByIdOrCreate<T: NSManagedObject>(_ entityType: T.Type,
                                                   identifier: PredicateConvertible,
                                                   identifierKey: String = NSPredicate.Constant.defaultIdKey,
                                                   inContext context: NSManagedObjectContext,
                                                   andPredicateFormat format: String? = nil,
                                                   argumentArray: [Any]? = nil) -> T {
        let predicate = NSPredicate.objectWithIDPredicate(identifier,
                                                          identifierKey: identifierKey,
                                                          andPredicateFormat: format,
                                                          argumentArray: argumentArray)
        return findFirstOrCreate(entityType,
                                 withPredicate: predicate,
                                 inContext: context)
    }

    /// Finds first entity that matches identifier and additional predicate
    /// See also [findFirstByIdOrCreate](x-source-tag://PredicateConvertible) for more info
    /// - Parameters:
    ///   - entityType: A type of entity to find
    ///   - identifier: The identifier of entity, an object that adopts [PredicateConvertible](x-source-tag://PredicateConvertible)
    ///   - context: NSManagedObjectContext where entity should be find
    ///   - format: Format for additional predicate. See [objectWithIDPredicate](x-source-tag://PredicateConvertible)
    ///   - argumentArray: Array of arguments for additional predicate. See [objectWithIDPredicate](x-source-tag://PredicateConvertible)
    /// - Returns: First found entity or nil.
    func findFirstById<T: NSManagedObject>(_ entityType: T.Type,
                                           identifier: PredicateConvertible,
                                           identifierKey: String = NSPredicate.Constant.defaultIdKey,
                                           inContext context: NSManagedObjectContext,
                                           andPredicateFormat format: String? = nil,
                                           argumentArray: [Any]? = nil) -> T? {
        let predicate = NSPredicate.objectWithIDPredicate(identifier,
                                                          identifierKey: identifierKey,
                                                          andPredicateFormat: format,
                                                          argumentArray: argumentArray)
        return findFirst(entityType, withPredicate: predicate, inContext: context)
    }

}
