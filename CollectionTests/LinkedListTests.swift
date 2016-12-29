//
//  LinkedListTests.swift
//  CollectionTests
//
//  Created by Alexander Zalutskiy on 28.12.16.
//  Copyright © 2016 Alexander Zalutskiy. All rights reserved.
//

import XCTest
@testable import Collection

class LinkedListTests: XCTestCase {

	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testAppendContentsOf() {
		let list = LinkedList<Int>()
		list.append(contentsOf: [1, 2, 3])

		XCTAssertEqual(list[0], 1)
		XCTAssertEqual(list[1], 2)
		XCTAssertEqual(list[2], 3)

		XCTAssertEqual(list.count, 3)

		list.append(contentsOf: [4, 5, 6], at: 0)

		XCTAssertEqual(list[0], 4)
		XCTAssertEqual(list[1], 5)
		XCTAssertEqual(list[2], 6)
		XCTAssertEqual(list[3], 1)
		XCTAssertEqual(list[4], 2)
		XCTAssertEqual(list[5], 3)

		XCTAssertEqual(list.count, 6)

		list.append(contentsOf: [7, 8, 9], at: 3)

		XCTAssertEqual(list[0], 4)
		XCTAssertEqual(list[1], 5)
		XCTAssertEqual(list[2], 6)
		XCTAssertEqual(list[3], 7)
		XCTAssertEqual(list[4], 8)
		XCTAssertEqual(list[5], 9)
		XCTAssertEqual(list[6], 1)
		XCTAssertEqual(list[7], 2)
		XCTAssertEqual(list[8], 3)

		XCTAssertEqual(list.count, 9)


		// TODO: test on fatal error
		//		XCTAssertThrowsError(list.addAll(from: [1], at: 20))
	}

	func testFirstLast() {

		let list = LinkedList(collection: [1, 2, 3, 4, 5, 6, 7, 8, 9, 0])

		XCTAssertEqual(list.first, 1)
		XCTAssertEqual(list.last, 0)

		let list2 = LinkedList<Int>()

		XCTAssertNil(list2.first)
		XCTAssertNil(list2.last)

	}

	func testAppend() {

		let list = LinkedList<Int>()

		list.append(1)

		XCTAssertEqual(list[0], 1)
		XCTAssertEqual(list.count, 1)

		list.append(2)

		XCTAssertEqual(list[1], 2)
		XCTAssertEqual(list.count, 2)

	}

	func testIndexOf() {
		let list = LinkedList<Int>()
		list.append(contentsOf: [0, 1, 2, 3, 4])

		XCTAssertEqual(list.index(of: 3), 3)
	}

	func testForIn() {
		let list = LinkedList(collection: [0, 1, 2, 3, 4])

		for i in list {
			print(i)
		}
	}

}
