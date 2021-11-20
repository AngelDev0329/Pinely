//
//  URL+getDocumentsDirectory.swift
//  Pinely
//

import Foundation

extension URL {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    static func getFileInDocumentsDirectory(_ fileName: String) -> URL {
        URL.getDocumentsDirectory().appendingPathComponent(fileName)
    }
}
