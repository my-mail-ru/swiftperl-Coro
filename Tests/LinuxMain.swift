import XCTest

@testable import PerlCoroTests

var tests = [XCTestCaseEntry]()
tests += [testCase(PerlCoroTests.allTests)]
XCTMain(tests)
