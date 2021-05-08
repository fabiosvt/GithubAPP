import UIKit
import Alamofire
class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView()
    var users: [GithubUser] = []
    var usersFiltered: [GithubUser] = []
    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    var loading = false
    var currentPage = 0
    var searching : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Git users"
        setupTableView()
        fetchUsers()
    }
    func setupTableView() {
        let headerView:UIView = UIView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:60))
        tableView.tableHeaderView = headerView
        tableView.addSubview(searchBar)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return usersFiltered.count
        } else {
            return users.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "identifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: identifier)
        }
        if searching {
            cell?.textLabel?.text = usersFiltered[indexPath.row].login
            cell?.detailTextLabel?.text = usersFiltered[indexPath.row].url
        } else {
            cell?.textLabel?.text = users[indexPath.row].login
            cell?.detailTextLabel?.text = users[indexPath.row].url
        }
        cell?.detailTextLabel?.font = UIFont .systemFont(ofSize: CGFloat(13))
        cell?.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell!
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let push = DetailViewController(user: users[indexPath.row])
        //self.present(push, animated: true, completion: nil)
        self.navigationController?.pushViewController(push, animated: true)
    }
    private func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.init(rawValue: 1)!
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if (offsetY > contentHeight - scrollView.frame.height * 4) && !loading {
            fetchUsers()
        }
    }
}
extension TableViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searching = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searching = false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searching = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searching = false
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        usersFiltered = self.users.filter({$0.login.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tableView.reloadData()
    }
    func fetchUsers() {
        AF.request("https://api.github.com/users").validate().responseDecodable(of: [GithubUser].self) { (response) in
            switch response.result {
            case .success(let val):
                for f in val {
                    self.users.append(f)
                }
                self.tableView.reloadData()
                return
            case .failure(let err):
                print(err)
                return
            }
        }
    }
}
