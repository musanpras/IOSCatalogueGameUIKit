import UIKit

final class FavoritesViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let repo = FavoritesRepository.shared
    private var data: [Game] = []
    private let refresh = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        tableView.register(GameCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load()
    }
    @objc private func reloadData() {
        load()
    }
    private func load() {
        data = repo.all()
        tableView.reloadData()
        if refresh.isRefreshing { refresh.endRefreshing() }
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { data.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameCell
        let item = data[indexPath.row]
        cell.configure(with: item, isFav: true) { [weak self] id, game in
            self?.repo.toggle(game: game)
            self?.load()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = data[indexPath.row]
        navigationController?.pushViewController(GameDetailViewController(gameID: item.id, titleText: item.name), animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            guard let self else { return }
            let item = self.data[indexPath.row]
            self.repo.remove(id: item.id)
            self.load()
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
