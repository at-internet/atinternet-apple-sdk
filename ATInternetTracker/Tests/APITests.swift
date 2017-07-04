import Foundation

import XCTest
@testable import Tracker

class MockStore: SimpleStorageProtocol {
    var store: Any? = nil
    func getByName(_ name: String) -> Any? {return store}
    func saveByName(_ config: Any, name: String) -> Bool {store = config; return true}
}

class MockNetwork: SimpleNetworkService {
    func getURL(_ request: MappingRequest) {
        request.callback(ATJSON(["timestamp": 123456]))
    }
}

class APITests: XCTestCase {

    override func setUp() {
        /**
        We clean up the queue manager before any test
        Since we can't clean manually, we have to cancel everything + wait all op to finish/be canceled
        */
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testApiUrlGeneration() {
        let api = ApiS3Client( token: "test",
                              version: "1.1",
                              store: MockStore(),
                              networkService: MockNetwork(),
                              endPoint: "https://8me4zn67yd.execute-api.eu-west-1.amazonaws.com/prod/token/{token}/version/{version}")
        let url = api.getMappingURL()
        XCTAssertEqual(url, URL(string: "https://8me4zn67yd.execute-api.eu-west-1.amazonaws.com/prod/token/test/version/1.1"))
    }
    
    func testGetConfig() {
        let exp = expectation(description: "async")
        let store = MockStore()
        let api = ApiS3Client(token: "X", version: "1.0", store: store, networkService: MockNetwork(), endPoint: "{token}/version/{version}/")
        api.fetchMapping({(apiMapping: ATJSON?) in
            XCTAssertNotNil(apiMapping)
            XCTAssertNotNil(store.getByName("at_smartsdk_config"))
            exp.fulfill()
        })
        
        self.waitForExpectations(timeout: 0.5) { (err) in
            if let error = err {
                print("timeout error \(error)")
            }
        }
    }
    
    func testSaveTTL() {
        let store = MockStore()
        let api = ApiS3Client(token: "X", version: "1.0", store: store, networkService: MockNetwork(), endPoint: "{token}/version/{version}/")
        api.saveTTL()
        let ttl = store.getByName("at_smartsdk_ttl") as! Date
        let InOneHour = Date().addingTimeInterval(3600)
        let InOneHourTwenty = Date().addingTimeInterval(3600+60*20)
        XCTAssertTrue(ttl >= InOneHour && ttl <= InOneHourTwenty, "le TTL est mal calculé")
    }

    /*func testFetchMappingIfNoMappingInMemory() {
        let exp = expectation(description: "async")
        
        let api = ApiS3Client(token: "X", version: "1.0", store: MockStore(), networkService: MockNetwork())
        api.pullMapping({(apiMapping: ATJSON?) in
            XCTAssertNotNil(apiMapping)
            exp.fulfill()
        })
        
        self.waitForExpectations(timeout: 0.5) { (err) in
            if let error = err {
                print("timeout error \(error)")
            }
        }
    }*/
}
