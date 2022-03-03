//
//  UserTableHeaderViewTests.swift
//  MAGETests
//
//  Created by Daniel Barela on 7/10/20.
//  Copyright © 2020 National Geospatial Intelligence Agency. All rights reserved.
//

import Foundation
import Quick
import Nimble
//import Nimble_Snapshots
import MagicalRecord
import OHHTTPStubs

@testable import MAGE

class ContainingUIViewController: UIViewController {
    var viewDidLoadClosure: (() -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoadClosure?();
    }
}

class UserTableHeaderViewTests: KIFSpec {
    
    override func spec() {
        
        describe("UserTableHeaderView") {
            
            let recordSnapshots = false;
            
            var userTableHeaderView: UserTableHeaderView!
            var view: UIView!
            var controller: UIViewController!
            var window: UIWindow!;
            
//            func maybeRecordSnapshot(_ view: UIView, recordThisSnapshot: Bool = false, doneClosure: (() -> Void)?) {
//                print("Record snapshot?", recordSnapshots);
//                if (recordSnapshots || recordThisSnapshot) {
//                    DispatchQueue.global(qos: .userInitiated).async {
//                        Thread.sleep(forTimeInterval: 5.0);
//                        DispatchQueue.main.async {
//                            expect(view) == recordSnapshot(usesDrawRect: true);
//                            doneClosure?();
//                        }
//                    }
//                } else {
//                    doneClosure?();
//                }
//            }

            beforeEach {
                TestHelpers.clearAndSetUpStack();
                MageCoreDataFixtures.quietLogging();
                
                HTTPStubs.stubRequests(passingTest: { (request) -> Bool in
                    return request.url == URL(string: "https://magetest/api/users/userabc/icon");
                }) { (request) -> HTTPStubsResponse in
                    let stubPath = OHPathForFile("test_marker.png", type(of: self))
                    return HTTPStubsResponse(fileAtPath: stubPath!, statusCode: 200, headers: ["Content-Type": "image/png"]);
                };
                                
                controller = UIViewController();
                window = TestHelpers.getKeyWindowVisible();
                window.rootViewController = controller;
                view = UIView(forAutoLayout: ());
                view.backgroundColor = .systemBackground;
                controller.view.addSubview(view);
                view.autoPinEdgesToSuperviewEdges();
                
                Server.setCurrentEventId(1);
                UserDefaults.standard.mapType = 0;
                UserDefaults.standard.locationDisplay = .latlng;
                UserDefaults.standard.currentUserId = nil;
            }
            
            afterEach {
                controller.dismiss(animated: false, completion: nil);
                window.rootViewController = nil;
                controller = nil;
                HTTPStubs.removeAllStubs();
                TestHelpers.clearAndSetUpStack();
            }
            
            it("user view") {
                var completeTest = false;
                MageCoreDataFixtures.addUser()
                MageCoreDataFixtures.addLocation()
                
                let user: User = User.mr_findFirst()!;
                userTableHeaderView = UserTableHeaderView(forAutoLayout: ());
                userTableHeaderView.applyTheme(withContainerScheme: MAGEScheme.scheme());
                userTableHeaderView.populate(user: user);
                userTableHeaderView.start();
                view.addSubview(userTableHeaderView);
                userTableHeaderView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom);

//                maybeRecordSnapshot(userTableHeaderView, doneClosure: {
//                    completeTest = true;
//                })
                tester().expect(viewTester().usingLabel("name").view, toContainText: "User ABC");
                tester().expect(viewTester().usingLabel("location").view, toContainText: "40.10850, -104.36780  GPS +/- 266.16m");
                tester().expect(viewTester().usingLabel("303-555-5555").view, toContainText: "303-555-5555");
                tester().expect(viewTester().usingLabel("userabc@test.com").view, toContainText: "userabc@test.com");
                
//                if (recordSnapshots) {
//                    expect(completeTest).toEventually(beTrue(), timeout: DispatchTimeInterval.seconds(10), pollInterval: DispatchTimeInterval.seconds(1), description: "Test Complete");
//                } else {
//                    expect(completeTest).toEventually(beTrue(), timeout: DispatchTimeInterval.seconds(10), pollInterval: DispatchTimeInterval.seconds(1), description: "Test Complete");
//                    expect(userTableHeaderView).toEventually(haveValidSnapshot(usesDrawRect: true), timeout: DispatchTimeInterval.seconds(10), pollInterval: DispatchTimeInterval.seconds(1), description: "Map loaded")
//                }
            }
            
            it("current user view") {
                var completeTest = false;
                
                UserDefaults.standard.currentUserId = "userabc";
                
                window.rootViewController = controller;
                controller.view.addSubview(view);
                MageCoreDataFixtures.addUser()
                MageCoreDataFixtures.addGPSLocation()
                
                let user: User = User.mr_findFirst()!;
                userTableHeaderView = UserTableHeaderView(forAutoLayout: ());
                userTableHeaderView.applyTheme(withContainerScheme: MAGEScheme.scheme());
                userTableHeaderView.populate(user: user);
                userTableHeaderView.start();
                view.addSubview(userTableHeaderView);
                userTableHeaderView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom);
                                
                tester().expect(viewTester().usingLabel("name").view, toContainText: "User ABC");
                tester().expect(viewTester().usingLabel("location").view, toContainText: "40.10850, -104.36780  GPS +/- 4.20m");
                tester().expect(viewTester().usingLabel("303-555-5555").view, toContainText: "303-555-5555");
                tester().expect(viewTester().usingLabel("userabc@test.com").view, toContainText: "userabc@test.com");
                
//                maybeRecordSnapshot(userTableHeaderView, doneClosure: {
//                    completeTest = true;
//                })
//                
//                if (recordSnapshots) {
//                    expect(completeTest).toEventually(beTrue(), timeout: DispatchTimeInterval.seconds(10), pollInterval: DispatchTimeInterval.seconds(1), description: "Test Complete");
//                } else {
//                    expect(completeTest).toEventually(beTrue(), timeout: DispatchTimeInterval.seconds(10), pollInterval: DispatchTimeInterval.seconds(1), description: "Test Complete");
//                    expect(userTableHeaderView).toEventually(haveValidSnapshot(usesDrawRect: true), timeout: DispatchTimeInterval.seconds(10), pollInterval: DispatchTimeInterval.seconds(1), description: "Map loaded")
//                }
            }
            
            it("init with constructor") {
                MageCoreDataFixtures.addUser()
                MageCoreDataFixtures.addLocation()
                
                let user: User = User.mr_findFirst()!;
                userTableHeaderView = UserTableHeaderView(user: user, scheme: MAGEScheme.scheme());
                userTableHeaderView.start();
                view.addSubview(userTableHeaderView);
                userTableHeaderView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom);

                tester().expect(viewTester().usingLabel("name").view, toContainText: "User ABC");
                tester().expect(viewTester().usingLabel("location").view, toContainText: "40.10850, -104.36780  GPS +/- 266.16m");
                tester().expect(viewTester().usingLabel("303-555-5555").view, toContainText: "303-555-5555");
                tester().expect(viewTester().usingLabel("userabc@test.com").view, toContainText: "userabc@test.com");
            }
        }
        
    }
}
