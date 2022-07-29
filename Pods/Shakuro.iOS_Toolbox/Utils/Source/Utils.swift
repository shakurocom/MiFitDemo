//
// Copyright (c) 2020 Shakuro (https://shakuro.com/)
// Sergey Laschuk
//
// Some of the code was borrowed from here: https://forums.swift.org/t/get-value-after-assigning-string-any-to-string-any/10595/3
//
// TODO: tests

/// Reflects objects to traverse all relations to find all objects of ResultType (including parent).
public func traverse<ResultType>(parent: Any, found: inout Set<ResultType>) where ResultType: Hashable {
    let parentMirror = Mirror(reflecting: parent)
    let realChildren = parentMirror.children.compactMap({ (child: (label: String?, value: Any)) -> Any? in
        guard child.label != nil else {
            return nil
        }
        switch optionalPromotingCast(child.value) {
        case .none: return nil
        default: return child.value
        }
    })
    if let castParent = parent as? ResultType {
        if found.contains(castParent) {
            return
        } else {
            found.insert(castParent)
        }
    }
    realChildren.forEach({ traverse(parent: $0, found: &found) })
}

/// Cast from `Any` to `Any?`.
public func optionalPromotingCast<T>(_ value: T) -> T? {
    // NOTE: we hide forcecast to optional with generic function from compiler.
    //  This will delay actual cast until runtime.
    //  Runtime will check if type is already optional and promote to optional otherwise.
    //
    //  This is used above for obtaining values via AnyKeyPath.
    //  Actual values of properties can be of many types: Int, Object, List (optional and not).
    //  As a result we use Any as a base type.
    //  But then we need to extract actual values from this Any:
    //  - 'nil' values should be skipped
    //  - known types should be processed
    //  - unknown types should assert()'ed
    //
    //  https://forums.swift.org/t/get-value-after-assigning-string-any-to-string-any/10595/3
    func forceCast<T, U>(_ value: T, to _: U.Type) -> U {
        return value as! U // swiftlint:disable:this force_cast
    }
    return forceCast(value, to: T?.self)
}
