import Foundation

extension Bool {
    var asString: String {
        return self == true ? "true" : "false"
    }
}

extension Int {
    var asString: String {
        return "\(self)"
    }
}
