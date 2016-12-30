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

	var list: LinkedList<Int>!

	override func setUp() {
		super.setUp()
		list = [1, 2, 3, 4, 5, 6, 5, 4, 3]
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

		list.insert(contentsOf: [4, 5, 6], at: 0)

		XCTAssertEqual(list[0], 4)
		XCTAssertEqual(list[1], 5)
		XCTAssertEqual(list[2], 6)
		XCTAssertEqual(list[3], 1)
		XCTAssertEqual(list[4], 2)
		XCTAssertEqual(list[5], 3)

		XCTAssertEqual(list.count, 6)

		list.insert(contentsOf: [7, 8, 9], at: 3)

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
		XCTAssertEqual(list.first, 1)
		XCTAssertEqual(list.last, 3)

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
		XCTAssertEqual(list.index(of: 3), 2)
		XCTAssertNil(list.index(of: 10))
	}

	func testContains() {
		XCTAssertTrue(list.contains(2))
		XCTAssertFalse(list.contains(10))
	}

	func testForIn() {
		var count = 0
		for _ in list {
			count += 1
		}
		XCTAssertEqual(list.count, count)
	}

	func testRemoveFirst() {
		XCTAssertEqual(list.removeFirst(), 1)
		XCTAssertEqual(list.first, 2)
		XCTAssertEqual(list.count, 8)
		XCTAssertNotEqual(list.modCount, 0)
	}

	func testRemoveLast() {
		XCTAssertEqual(list.removeLast(), 3)
		XCTAssertEqual(list.last, 4)
		XCTAssertEqual(list.count, 8)
		XCTAssertNotEqual(list.modCount, 0)
	}

	func testInsert1() {
		list.insert(5, at: 2)
		XCTAssertEqual(list.count, 10)
		XCTAssertEqual(list[1], 2)
		XCTAssertEqual(list[2], 5)
		XCTAssertEqual(list[3], 3)
		XCTAssertNotEqual(list.modCount, 0)
	}

	func testInsert2() {
		list.insert(9, at: 9)
		XCTAssertEqual(list.count, 10)
		XCTAssertEqual(list[8], 3)
		XCTAssertEqual(list[9], 9)
		XCTAssertNotEqual(list.modCount, 0)
	}

	func testContainsWhere() {
		XCTAssertTrue(list.contains { $0 % 2 == 0 })
		XCTAssertFalse(list.contains { $0 > 10 })
	}

	func testRemoveWhere() {
		XCTAssertEqual(list.remove { $0 > 3 }, 4)
		XCTAssertEqual(list.count, 8)
		XCTAssertEqual(list[2], 3)
		XCTAssertEqual(list[3], 5)
		XCTAssertEqual(list[4], 6)
		XCTAssertNotEqual(list.modCount, 0)

		let oldModCount = list.modCount
		XCTAssertNil(list.remove { $0 > 10 })
		XCTAssertEqual(oldModCount, list.modCount)
	}

	func testRemoveElement() {
		XCTAssertTrue(list.remove(3))
		XCTAssertEqual(list.count, 8)
		XCTAssertNotEqual(list.modCount, 0)

		let oldModCount = list.modCount
		XCTAssertFalse(list.remove(10))
		XCTAssertEqual(oldModCount, list.modCount)
	}

	func testRemoveAll() {
		list.removeAll()
		XCTAssertEqual(list.count, 0)
		XCTAssertNotEqual(list.modCount, 0)
		XCTAssertNil(list.firstNode)
		XCTAssertNil(list.lastNode)
	}

	func testSubscriptSet() {
		list[2] = 10
		XCTAssertEqual(list[2], 10)
		XCTAssertNotEqual(list.modCount, 0)
	}

	func testLastIndexWhere() {
		XCTAssertEqual(list.lastIndex { $0 > 4 }, 6)
		XCTAssertNil(list.lastIndex { $0 < 0})
	}

	func testLastWhere() {
		XCTAssertEqual(list.last { $0 >= 2 }, 3)
		XCTAssertNil(list.last { $0 > 10 })
	}

}
