import UIKit

final class GameCell: UITableViewCell {
    private let cover = UIImageView()
    private let titleLabel = UILabel()
    private let ratingLabel = UILabel()
    private let releaseLabel = UILabel()
    private let fav = UIButton(type: .system)
    private var id: Int?
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.layer.cornerRadius = 8
        cover.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        ratingLabel.font = .preferredFont(forTextStyle: .subheadline)
        ratingLabel.textColor = .secondaryLabel
        releaseLabel.font = .preferredFont(forTextStyle: .subheadline)
        releaseLabel.textColor = .secondaryLabel
        fav.setImage(UIImage(systemName: "heart"), for: .normal)
        fav.addTarget(self, action: #selector(toggleFav), for: .touchUpInside)
        let v = UIStackView(arrangedSubviews: [titleLabel, ratingLabel, releaseLabel])
        v.axis = .vertical
        v.spacing = 4
        let h = UIStackView(arrangedSubviews: [cover, v, fav])
        h.alignment = .center
        h.spacing = 12
        contentView.addSubview(h)
        cover.translatesAutoresizingMaskIntoConstraints = false
        h.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: cover.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: cover.centerYAnchor),
            cover.widthAnchor.constraint(equalToConstant: 64),
            cover.heightAnchor.constraint(equalToConstant: 64),
            fav.widthAnchor.constraint(equalToConstant: 24),
            fav.heightAnchor.constraint(equalToConstant: 20),
            h.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            h.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            h.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            h.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        activityIndicator.hidesWhenStopped = true
    }
    required init?(coder: NSCoder) { nil }
    func configure(with item: Game) {
        id = item.id
        titleLabel.text = item.name
        let rating = item.rating.map { String(format: "%.1f ★", $0) } ?? "No rating"
        let released = item.released ?? "—"
        ratingLabel.text = "\(rating)"
        releaseLabel.text = "Released: \(released)"
        Task {
            activityIndicator.startAnimating()
            cover.image = await ImageLoader.shared.load(item.backgroundImage)
            activityIndicator.stopAnimating()
        }
        updateFavIcon()
    }
    private func updateFavIcon() {
        guard let id else { return }
        let on = FavoritesStore.shared.isFavorite(id: id)
        let name = on ? "heart.fill" : "heart"
        fav.tintColor = .systemPink
        fav.setImage(UIImage(systemName: name), for: .normal)
    }
    @objc private func toggleFav() {
        guard let id else { return }
        FavoritesStore.shared.toggle(id: id)
        updateFavIcon()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
