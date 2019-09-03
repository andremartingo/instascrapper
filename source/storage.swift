//
//  storage.swift
//  instagram
//
//  Created by Andre Martingo on 19.08.19.
//  Copyright © 2019 Andre Martingo. All rights reserved.
//

import Foundation

enum LocalStorage {
    static let storageName = documentURL(with: "instagram.json")
    
    private static func documentURL(with filename: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let documentsDirectory = paths.first else {
            fatalError("💥 Failed to get first value of \(paths)")
        }
        
        let path = documentsDirectory.appendingPathComponent(filename)
        
        return path
    }
    
    static func write<T: Encodable>(collection: T, to localURL: URL = storageName) throws {
        do {
            let data: Data = try JSONEncoder().encode(collection)
            try data.write(to: localURL, options: .atomic)
        } catch {
            throw error
        }
    }

    static func read<T: Decodable>(from localURL: URL = storageName) -> T? {
        do {
            let data = try Data(contentsOf: localURL)
            let content = try JSONDecoder().decode(T.self, from: data)
            return content
        } catch {
            return nil
        }
    }
}

