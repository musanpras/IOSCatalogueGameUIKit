import UIKit

final class GamesListViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let service: GameServiceProtocol = GameService()
    private var data: [Game] = []
    private var nextURL: URL?
    private var isLoading = false
    private var searchController = UISearchController(searchResultsController: nil)
    private var searchTask: Task<Void, Never>?
    private let refresh = UIRefreshControl()
    private let favorites = FavoritesRepository.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Games"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        tableView.register(GameCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(pulled), for: .valueChanged)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        setupSearch()
        Task { await loadInitial() }
    }
    private func setupSearch() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search games"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    @objc private func pulled() {
        Task { await loadInitial(force: true) }
    }
    private func updateSnapshot(_ new: [Game], next: URL?) {
        data = new
        nextURL = next
        tableView.reloadData()
    }
    private func appendSnapshot(_ more: [Game], next: URL?) {
        data.append(contentsOf: more)
        nextURL = next
        tableView.reloadData()
    }
    private func endRefreshing() {
        if refresh.isRefreshing { refresh.endRefreshing() }
    }
    private func setLoading(_ value: Bool) {
        isLoading = value
        if value { UISelectionFeedbackGenerator().selectionChanged() }
    }
    private func currentQuery() -> String {
        searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    private func hasQuery() -> Bool {
        !currentQuery().isEmpty
    }
    private func makeFooterSpinner() -> UIActivityIndicatorView {
        let s = UIActivityIndicatorView(style: .medium)
        s.startAnimating()
        s.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        return s
    }
    private func clearFooter() {
        tableView.tableFooterView = UIView(frame: .zero)
    }
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    @MainActor private func loadInitial(force: Bool = false) async {
        if isLoading { return }
        setLoading(true)
        defer { setLoading(false); endRefreshing() }
        do {
            let resp: GameListResponse
            if hasQuery() && !force {
                resp = try await service.searchGames(query: currentQuery())
            } else {
                resp = try await service.fetchGames(url: nil)
            }
            updateSnapshot(resp.results, next: resp.next)
        } catch {
            showError("Failed to load games.")
        }
    }
    @MainActor private func loadMore() async {
        if isLoading { return }
        guard let next = nextURL else { return }
        tableView.tableFooterView = makeFooterSpinner()
        setLoading(true)
        defer { setLoading(false); clearFooter() }
        do {
            let resp = try await service.fetchGames(url: next)
            appendSnapshot(resp.results, next: resp.next)
        } catch { }
    }
}

extension GamesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { data.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameCell
        let item = data[indexPath.row]
        cell.configure(with: item, isFav: favorites.isFavorite(id: item.id)) { [weak self] id, game in

                    self?.favorites.toggle(game: game)

                    tableView.reloadRows(at: [indexPath], with: .automatic)

                }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = data[indexPath.row]
        navigationController?.pushViewController(GameDetailViewController(gameID: item.id, titleText: item.name), animated: true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height * 1.5 {
            Task { await loadMore() }
        }
    }
}

extension GamesListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = currentQuery()
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 450_000_000)
            guard !Task.isCancelled else { return }
            if query.isEmpty {
                await self?.loadInitial()
            } else {
                do {
                    let resp = try await self?.service.searchGames(query: query)
                    await MainActor.run {
                        self?.updateSnapshot(resp?.results ?? [], next: resp?.next)
                    }
                } catch { }
            }
        }
    }
}
