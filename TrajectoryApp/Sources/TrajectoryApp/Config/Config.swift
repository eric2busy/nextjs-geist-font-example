import Foundation

enum Config {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }
    
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }
        
        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

enum SupabaseConfig {
    static var projectURL: URL {
        get throws {
            let urlString: String = try Config.value(for: "SUPABASE_PROJECT_URL")
            guard let url = URL(string: urlString) else {
                throw Config.Error.invalidValue
            }
            return url
        }
    }
    
    static var anonKey: String {
        get throws {
            try Config.value(for: "SUPABASE_ANON_KEY")
        }
    }
    
    static var realtimeEnabled: Bool {
        get throws {
            try Config.value(for: "SUPABASE_ENABLE_REALTIME")
        }
    }
}

enum GrokConfig {
    static var apiKey: String {
        get throws {
            try Config.value(for: "GROK_API_KEY")
        }
    }
    
    static var maxTokens: Int {
        get throws {
            try Config.value(for: "GROK_MAX_TOKENS")
        }
    }
}

extension Config {
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var environment: String {
        #if DEBUG
        return "development"
        #else
        return "production"
        #endif
    }
}
