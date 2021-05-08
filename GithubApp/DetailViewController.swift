import UIKit
import SnapKit
import Alamofire
class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    let photoview: UIImageView
    let loginLabel: UILabel
    let user: GithubUser
    var searching : Bool = false
    var userInfo: GithubUser!
    let tableView = UITableView()
    var repos: [GithubRepos] = []
    var reposFiltered: [GithubRepos] = []
    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    init(user: GithubUser) {
        self.photoview = UIImageView()
        self.loginLabel = UILabel()
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupTableView() {
        let headerView:UIView = UIView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:60))
        tableView.tableHeaderView = headerView
        tableView.addSubview(searchBar)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.view.backgroundColor = UIColor.white
        photoview.backgroundColor = UIColor.red
        self.view.addSubview(photoview)
        self.view.addSubview(loginLabel)
        view.addSubview(tableView)
        photoview.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(200)
            make.centerX.equalTo(self.view)
            make.top.equalToSuperview().offset(100)
        }
        loginLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(photoview.snp.bottom).offset(20)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(loginLabel.snp.top).offset(50)
            make.bottom.equalToSuperview().offset(50)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        fetchUser()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    func fetchUser() {
        AF.request("https://api.github.com/users/"+self.user.login).validate().responseDecodable(of: GithubUser.self) { [self] (response) in
            switch response.result {
            case .success(let val):
                self.userInfo = val
                loginLabel.text = self.userInfo.login
                loginLabel.backgroundColor = UIColor.red
                if let http = URL(string: self.userInfo.avatar_url ?? "") {
                    var comps = URLComponents(url: http, resolvingAgainstBaseURL: false)!
                    comps.scheme = "https"
                    if let https = comps.url {
                        let task = URLSession.shared.dataTask(with: https) { data, response, error in
                            guard let data = data, error == nil else { return }
                            DispatchQueue.main.async {
                                if let image = UIImage(data: data) {
                                    self.photoview.image = image
                                }
                            }
                        }
                        task.resume()
                    }
                }
                fetchRepos()
                return
            case .failure(let err):
                print(err)
                return
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return reposFiltered.count
        } else {
            return repos.count
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
            cell?.textLabel?.text = reposFiltered[indexPath.row].name
            cell?.detailTextLabel?.text = reposFiltered[indexPath.row].url
        } else {
            cell?.textLabel?.text = repos[indexPath.row].name
            cell?.detailTextLabel?.text = repos[indexPath.row].url
        }
        cell?.detailTextLabel?.font = UIFont .systemFont(ofSize: CGFloat(13))
        cell?.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell!
    }
    private func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.init(rawValue: 1)!
    }
    func fetchRepos() {
        AF.request("https://api.github.com/users/"+self.user.login+"/repos").validate().responseDecodable(of: [GithubRepos].self) { [self] (response) in
            print(response.result)
            switch response.result {
              case .success(let val):
                for f in val {
                    self.repos.append(f)
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
extension DetailViewController: UISearchBarDelegate{
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
        reposFiltered = self.repos.filter({$0.url.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tableView.reloadData()
    }
}
