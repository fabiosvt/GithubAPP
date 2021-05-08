import SnapshotTesting
import XCTest
@testable import GithubApp
class GithubAppTests: XCTestCase {
    func testView1() {
        super.setUp()
        let users = GithubUser.dummyUsers()
        let sut = TableViewController()
        sut.users = users!
        assertSnapshot(matching: sut, as: .image)

    }
    func testView2() {
        super.setUp()
        let user = GithubUser.dummyUser()
        let repos = GithubRepos.dummyRepos()
        let sut = DetailViewController(user: user!)
        sut.repos = repos!
        assertSnapshot(matching: sut, as: .image)

    }
}
