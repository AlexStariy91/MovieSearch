//
//  JSONDecoderManager.swift
//  MovieSearch
//
//  Created by Alexander Starodub on 30.01.2024.
//

import Foundation

enum JSONDecodeError: Error {
    case decodingFailed(reason: String)
}

class JSONDecoderManager {
    
    static let shared = JSONDecoderManager()
    
    private init() {}
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch let error as DecodingError {
            let reason: String
            switch error {
            case .dataCorrupted(let context):
                reason = "Data corrupted: \(context)"
            case .keyNotFound(let key, let context):
                reason = "Key '\(key)' not found: \(context)"
            case .typeMismatch(let type, let context):
                reason = "Type mismatch: \(type) - \(context)"
            case .valueNotFound(let value, let context):
                reason = "Value not found: \(value) - \(context)"
            @unknown default:
                reason = "Unknown decoding error"
            }
            
            throw JSONDecodeError.decodingFailed(reason: reason)
        } catch {
            throw JSONDecodeError.decodingFailed(reason: "Unexpected error: \(error)")
        }
    }
}
