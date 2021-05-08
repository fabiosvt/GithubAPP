def mypods
    pod 'Alamofire', '~> 5.0.0-beta.5'
    pod 'SnapKit'
end

def testpods
    mypods
    pod 'SnapshotTesting', '~> 1.8.2'
end

target 'GithubApp' do
    mypods
end

target 'GithubAppTests' do
    testpods
end
