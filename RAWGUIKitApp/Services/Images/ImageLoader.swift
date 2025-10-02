import UIKit

actor ImageCache {
    private var cache = NSCache<NSURL, UIImage>()
    func image(for url: NSURL) -> UIImage? {
        cache.object(forKey: url)
    }
    func insert(_ image: UIImage, for url: NSURL) {
        cache.setObject(image, forKey: url)
    }
}

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = ImageCache()
    private let session: URLSession
    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        session = URLSession(configuration: config)
    }
    func load(_ url: URL?) async -> UIImage? {
        guard let url else { return nil }
        let key = url as NSURL
        if let cached = await cache.image(for: key) { return cached }
        do {
            let (data, _) = try await session.data(from: url)
            if let img = UIImage(data: data) {
                await cache.insert(img, for: key)
                return img
            }
        } catch { }
        return nil
    }
}
