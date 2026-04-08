import Foundation

public enum EntityLookupKey {
    public static func performer(_ displayName: String) -> String {
        normalizedValue(for: displayName)
    }

    public static func brand(_ displayName: String) -> String {
        normalizedValue(for: displayName)
    }

    public static func venue(name: String, city: String?) -> String {
        let normalizedName = normalizedValue(for: name)
        let normalizedCity = city.map(normalizedValue(for:))

        guard let normalizedCity, !normalizedCity.isEmpty else {
            return normalizedName
        }

        return "\(normalizedName)::\(normalizedCity)"
    }

    public static func normalizedValue(for rawValue: String) -> String {
        rawValue
            .precomposedStringWithCompatibilityMapping
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
