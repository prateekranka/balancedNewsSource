import Foundation

enum PoliticalLeaning: String, CaseIterable, Identifiable {
    case left = "Left-Leaning"
    case center = "Centrist"
    case right = "Right-Leaning"

    var id: String { rawValue }

    var tabIcon: String {
        switch self {
        case .left: return "arrow.left.circle"
        case .center: return "circle.grid.cross"
        case .right: return "arrow.right.circle"
        }
    }
}
