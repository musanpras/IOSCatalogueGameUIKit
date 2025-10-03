import Foundation

struct Profile {
    var name: String
    var title: String
    var bio: String
}

final class ProfileStore {
    static let shared = ProfileStore()
    private let d = UserDefaults.standard
    private let kName = "profile.name"
    private let kTitle = "profile.title"
    private let kBio = "profile.bio"
    private init() { }
    func load() -> Profile {
        let name = d.string(forKey: kName) ?? "Muhammad Sandy"
        let title = d.string(forKey: kTitle) ?? "iOS Developer"
        let bio = d.string(forKey: kBio) ?? "iOS developer with a passion for clean UIKit architecture, performance, and delightful UX."
        return Profile(name: name, title: title, bio: bio)
    }
    func save(_ p: Profile) {
        d.set(p.name, forKey: kName)
        d.set(p.title, forKey: kTitle)
        d.set(p.bio, forKey: kBio)
    }
}
