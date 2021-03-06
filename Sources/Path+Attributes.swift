import Foundation

public extension Path {
    //MARK: Filesystem Attributes

    /**
     Returns the creation-time of the file.
     - Note: Returns UNIX-time-zero if there is no creation-time, this should only happen if the file doesn’t exist.
     */
    var ctime: Date {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: string)
            return attrs[.creationDate] as? Date ?? Date(timeIntervalSince1970: 0)
        } catch {
            //TODO log error
            return Date(timeIntervalSince1970: 0)
        }
    }

    /**
     Returns the modification-time of the file.
     - Note: Returns the creation time if there is no modification time.
     - Note: Returns UNIX-time-zero if neither are available, this should only happen if the file doesn’t exist.
     */
    var mtime: Date {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: string)
            return attrs[.modificationDate] as? Date ?? ctime
        } catch {
            //TODO log error
            return Date(timeIntervalSince1970: 0)
        }
    }

    /**
     Sets the file’s attributes using UNIX octal notation.

         Path.home.join("foo").chmod(0o555)
     */
    @discardableResult
    func chmod(_ octal: Int) throws -> Path {
        try FileManager.default.setAttributes([.posixPermissions: octal], ofItemAtPath: string)
        return self
    }
    
    /// - Note: If file is already locked, does nothing
    /// - Note: If file doesn’t exist, throws
    @discardableResult
    func lock() throws -> Path {
        var attrs = try FileManager.default.attributesOfItem(atPath: string)
        let b = attrs[.immutable] as? Bool ?? false
        if !b {
            attrs[.immutable] = true
            try FileManager.default.setAttributes(attrs, ofItemAtPath: string)
        }
        return self
    }

    /// - Note: If file isn‘t locked, does nothing
    /// - Note: If file doesn’t exist, does nothing
    @discardableResult
    func unlock() throws -> Path {
        var attrs: [FileAttributeKey: Any]
        do {
            attrs = try FileManager.default.attributesOfItem(atPath: string)
        } catch CocoaError.fileReadNoSuchFile {
            return self
        }
        let b = attrs[.immutable] as? Bool ?? false
        if b {
            attrs[.immutable] = false
            try FileManager.default.setAttributes(attrs, ofItemAtPath: string)
        }
        return self
    }
}
