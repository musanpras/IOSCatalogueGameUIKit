import UIKit

final class AboutViewController: UIViewController {
    private let avatar = UIImageView()
    private let nameLabel = UILabel()
    private let titleLabel = UILabel()
    private let bioLabel = UILabel()
    private let stack = UIStackView()
    private let edit = UIButton(type: .custom)
    private var profile = ProfileStore.shared.load()
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
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .secondaryLabel
        bioLabel.font = .preferredFont(forTextStyle: .body)
        bioLabel.numberOfLines = 0
        edit.setTitle("Edit Profile", for: .normal)
        edit.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        edit.backgroundColor = .darkGray
        edit.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        edit.layer.cornerRadius = 10
        edit.clipsToBounds = true
        edit.layer.shadowColor = UIColor.black.cgColor
        edit.layer.shadowOffset = CGSize(width: 0, height: 5)
        edit.layer.shadowRadius = 5
        edit.layer.shadowOpacity = 0.5
        edit.layer.masksToBounds = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        [avatar, nameLabel, titleLabel, bioLabel, edit].forEach { stack.addArrangedSubview($0) }
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 96),
            avatar.heightAnchor.constraint(equalToConstant: 96),
            edit.widthAnchor.constraint(equalToConstant: 150),
            edit.heightAnchor.constraint(equalToConstant: 50),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        apply()
    }
    private func apply() {
        profile = ProfileStore.shared.load()
        nameLabel.text = profile.name
        titleLabel.text = profile.title
        bioLabel.text = profile.bio
    }
    @objc private func editProfile() {
        let vc = EditProfileViewController(profile: profile) { [weak self] newProfile in
            ProfileStore.shared.save(newProfile)
            self?.apply()
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}
