import UIKit

final class AboutViewController: UIViewController {
    private let avatar = UIImageView()
    private let nameLabel = UILabel()
    private let titleLabel = UILabel()
    private let bioLabel = UILabel()
    private let stack = UIStackView()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        avatar.image = UIImage(named: "profilePict")
        avatar.contentMode = .scaleAspectFill
        avatar.layer.cornerRadius = 48
        avatar.clipsToBounds = true
        nameLabel.font = .preferredFont(forTextStyle: .title1)
        nameLabel.text = "Muhammad Sandy"
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = "iOS Developer"
        bioLabel.font = .preferredFont(forTextStyle: .body)
        bioLabel.numberOfLines = 0
        bioLabel.text = "iOS developer with a passion for clean UIKit architecture, performance, and delightful UX."
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        [avatar, nameLabel, titleLabel, bioLabel].forEach { stack.addArrangedSubview($0) }
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 96),
            avatar.heightAnchor.constraint(equalToConstant: 96),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}
