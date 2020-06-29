import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MoyaNetworkClient_CombineTests.allTests),
    ]
}
#endif
