import UIKit
import SafariServices

final class GameDetailViewController: UIViewController {
    private let scroll = UIScrollView()
    private let stack = UIStackView()
    private let cover = UIImageView()
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    private let textLabel = UILabel()
    private let action = UIButton(type: .custom)
    private let service: GameServiceProtocol = GameService()
    private let gameID: Int
    private let titleText: String
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    init(gameID: Int, titleText: String) {
        self.gameID = gameID
        self.titleText = titleText
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = titleText
        setupViews()
        Task { await load() }
    }
    private func setupViews() {
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.layer.cornerRadius = 12
        cover.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.numberOfLines = 0
        infoLabel.font = .preferredFont(forTextStyle: .subheadline)
        infoLabel.textColor = .secondaryLabel
        infoLabel.numberOfLines = 0
        textLabel.font = .preferredFont(forTextStyle: .body)
        textLabel.numberOfLines = 0
        action.backgroundColor = .darkGray
        action.setTitle("Go to Website", for: .normal)
        action.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        action.layer.cornerRadius = 10
        action.clipsToBounds = true
        action.layer.shadowColor = UIColor.black.cgColor
        action.layer.shadowOffset = CGSize(width: 0, height: 5)
        action.layer.shadowRadius = 5
        action.layer.shadowOpacity = 0.5
        action.layer.masksToBounds = false
        action.addTarget(self, action: #selector(touchDown), for: .touchDown)
        action.addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        stack.axis = .vertical
        stack.spacing = 12
        [cover, titleLabel, infoLabel, textLabel, action].forEach { stack.addArrangedSubview($0) }
        scroll.addSubview(stack)
        view.addSubview(scroll)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: cover.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: cover.centerYAnchor),
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            cover.heightAnchor.constraint(equalToConstant: 220)
        ])
        activityIndicator.hidesWhenStopped = true
    }
    @MainActor private func load() async {
        do {
            action.isHidden = true
            activityIndicator.startAnimating()
            let detail = try await service.fetchDetail(id: gameID)
            titleLabel.text = detail.name
            let g = (detail.genres ?? []).map { $0.name }.joined(separator: ", ")
            let rating = detail.rating.map { String(format: "%.1f ★", $0) } ?? "No rating"
            let meta = detail.metacritic.map { "Metacritic: \($0)" } ?? ""
            let rel = detail.released ?? "—"
            let play = detail.playtime.map { "\($0)h" } ?? "—"
            infoLabel.text = "\(rating) \(meta.isEmpty ? "" : "• \(meta)") • Released: \(rel) • Playtime: \(play) • Genres: \(g)"
            textLabel.text = detail.descriptionRaw ?? "No description"
            action.isHidden = detail.website == nil
            cover.image = await ImageLoader.shared.load(detail.backgroundImage)
            activityIndicator.stopAnimating()
            action.isHidden = false
            
        } catch {
            let alert = UIAlertController(title: "Error", message: "Failed to load detail.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc private func touchDown() {
        UIView.animate(withDuration: 0.15) { [self] in
                action.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                action.backgroundColor = .systemBlue.withAlphaComponent(0.8)
            }
        }

    @objc private func touchUp() {
        UIView.animate(withDuration: 0.2) { [self] in
                action.transform = .identity
                action.backgroundColor = .systemBlue
            }
            Task {
                do {
                    let detail = try await service.fetchDetail(id: gameID)
                    if let url = detail.website {
                        present(SFSafariViewController(url: url), animated: true)
                    }
                } catch { }
            }
        }
    
}
