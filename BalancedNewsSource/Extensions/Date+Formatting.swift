import Foundation

extension Date {

    /// A human-readable relative string such as "2 hr. ago" or "yesterday".
    /// Uses `RelativeDateTimeFormatter` with `.abbreviated` units style.
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}
