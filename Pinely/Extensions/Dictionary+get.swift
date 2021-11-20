//
//  Dictionary+get.swift
//  Pinely
//

import Foundation

// swiftlint:disable identifier_name
extension Dictionary where Key: ExpressibleByStringLiteral {
    // Full functions
    func getInt(_ key: Key, defVal: Int? = nil) -> Int? {
        let val = self[key]
        if val == nil {
            return defVal
        }

        if let ival = val as? Int {
            return ival
        }

        if let dval = val as? Double {
            return Int(dval)
        }

        if let sval = val as? String,
            let ival = Int(sval.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return ival
        }

        return defVal
    }

    func getLong(_ key: Key, defVal: Int64? = nil) -> Int64? {
        let val = self[key]
        if val == nil {
            return defVal
        }

        if let ival = val as? Int64 {
            return ival
        }

        if let dval = val as? Double {
            return Int64(dval)
        }

        if let sval = val as? String,
            let ival = Int64(sval.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return ival
        }

        return defVal
    }

    func getDouble(_ key: Key, defVal: Double? = nil) -> Double? {
        let val = self[key]
        if val == nil {
            return defVal
        }

        if let dval = val as? Double {
            return dval
        }

        if let ival = val as? Int {
            return Double(ival)
        }

        if let sval = val as? String,
            let dval = Double(sval.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return dval
        }

        return defVal
    }

    func getStringOrKey(_ key: Key) -> String {
        getString(key, defVal: "\(key)") ?? "\(key)"
    }

    func getString(_ key: Key, defVal: String? = nil) -> String? {
        let val = self[key]
        if val == nil {
            return defVal
        }

        if let sval = val as? String {
            return sval.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let ival = val as? Int {
            return "\(ival)"
        } else if let dval = val as? Double {
            return "\(dval)"
        } else if let bval = val as? Bool {
            return "\(bval)"
        }

        return defVal
    }

    func getBoolean(_ key: Key, defVal: Bool? = nil) -> Bool? {
        let val = self[key]
        if val == nil {
            return defVal
        }

        if let bval = val as? Bool {
            return bval
        }

        if let ival = val as? Int {
            return ival > 0
        }

        if let sval = val as? String {
            if let ival = Int(sval.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return ival > 0
            }

            let lcval = sval.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if lcval == "true" || lcval == "yes" {
                return true
            }
            if lcval == "false" || lcval == "no" {
                return false
            }
        }

        return defVal
    }
}
