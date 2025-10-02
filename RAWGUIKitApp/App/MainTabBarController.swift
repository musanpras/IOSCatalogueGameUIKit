import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let games = UINavigationController(rootViewController: GamesListViewController())
        games.tabBarItem = UITabBarItem(title: "Games", image: UIImage(systemName: "gamecontroller"), selectedImage: UIImage(systemName: "gamecontroller.fill"))
        let about = UINavigationController(rootViewController: AboutViewController())
        about.tabBarItem = UITabBarItem(title: "About", image: UIImage(systemName: "person.crop.circle"), selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        viewControllers = [games, about]
        tabBar.tintColor = .label
    }
}
