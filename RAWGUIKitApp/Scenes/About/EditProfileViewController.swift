import UIKit

final class EditProfileViewController: UIViewController {
    private let nameField = UITextField()
    private let titleField = UITextField()
    private let bioView = UITextView()
    private let onSave: (Profile) -> Void
    private var profile: Profile
    init(profile: Profile, onSave: @escaping (Profile) -> Void) {
        self.profile = profile
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { nil }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Profile"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        nameField.borderStyle = .roundedRect
        titleField.borderStyle = .roundedRect
        bioView.layer.cornerRadius = 8
        bioView.layer.borderWidth = 1
        bioView.layer.borderColor = UIColor.separator.cgColor
        nameField.text = profile.name
        titleField.text = profile.title
        bioView.text = profile.bio
        let stack = UIStackView(arrangedSubviews: [nameField, titleField, bioView])
        stack.axis = .vertical
        stack.spacing = 12
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bioView.heightAnchor.constraint(equalToConstant: 160)
        ])
        nameField.placeholder = "Name"
        titleField.placeholder = "Title"
    }
    @objc private func close() { dismiss(animated: true) }
    @objc private func save() {
        let p = Profile(name: nameField.text ?? "", title: titleField.text ?? "", bio: bioView.text ?? "")
        onSave(p)
        dismiss(animated: true)
    }
}
