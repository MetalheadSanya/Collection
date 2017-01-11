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

	func testInit() {

		list = LinkedList<Int>()
		XCTAssertEqual(list.count, 0)
		XCTAssertEqual(list._storage.modCount, 0)
	}

	func testCount() {

		XCTAssertEqual(list.count, 9)
	}

	func testIndexAfter() {

		let index = list.index(after: list.startIndex)
		XCTAssertEqual(index.node?.previous?.item, list.startIndex.node?.item)
	}

	func testIndexBefore() {

		let index = list.index(before: list.endIndex)
		XCTAssertNil(index.node?.next)
		XCTAssertEqual(index.node?.item, list._storage.last?.item)
	}

	func testFormIndexAfter() {

		let index = list.index(after: list.startIndex)
		var index2 = list.startIndex
		list.formIndex(after: &index2)
		XCTAssertEqual(index.node?.item, index2.node?.item)
	}

	func testSubscriptGet() {

		var index = list.startIndex

		XCTAssertEqual(list[index], 1)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 2)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 3)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 4)
	}

	func testSubscriptSet() {

		let index = list.index(list.startIndex, offsetBy: 2)
		list[index] = 10
		XCTAssertEqual(list[index], 10)
		XCTAssertNotEqual(list._storage.modCount, 0)
	}

	func testFormIndexBefore() {

		let index = list.index(before: list.endIndex)
		var index2 = list.endIndex
		list.formIndex(before: &index2)
		XCTAssertEqual(index, index2)
	}

	func testDistanceFromTo() {

		var index = list.startIndex
		for _ in 0 ..< 3 {
			list.formIndex(after: &index)
		}
		XCTAssertEqual(list.distance(from: list.startIndex, to: index), 3)
	}

	func testIndexOffsetBy1() {

		let n = 5
		var index = list.startIndex
		for _ in 0 ..< n {
			list.formIndex(after: &index)
		}
		XCTAssertEqual(list.index(list.startIndex, offsetBy: n), index)
	}

	func testIndexOffsetBy2() {

		let n = 5
		var index = list.endIndex
		for _ in 0 ..< n {
			list.formIndex(before: &index)
		}
		XCTAssertEqual(list.index(list.endIndex, offsetBy: -n), index)
	}

	func testFormIndexOffsetBy1() {

		var index = list.startIndex
		list.formIndex(&index, offsetBy: 5)
		XCTAssertEqual(list.index(list.startIndex, offsetBy: 5), index)
	}

	func testFormIndexOffsetBy2() {

		var index = list.endIndex
		list.formIndex(&index, offsetBy: -5)
		XCTAssertEqual(list.index(list.endIndex, offsetBy: -5), index)
	}

	func testIndexOffsetByLimitedBy() {

		let index = list.startIndex
		let limit = list.index(after: list.startIndex)
		XCTAssertNil(list.index(index, offsetBy: 5, limitedBy: limit))
		XCTAssertEqual(list.index(index, offsetBy: 5, limitedBy: list.endIndex),
		               list.index(index, offsetBy: 5))
	}

	func testFormIndexOffsetByLimitedBy() {

		var index = list.startIndex
		XCTAssertTrue(list.formIndex(&index, offsetBy: 5, limitedBy: list.endIndex))
		XCTAssertEqual(index, list.index(list.startIndex, offsetBy: 5))

		XCTAssertFalse(list.formIndex(&index,
		                              offsetBy: 10,
		                              limitedBy: list.endIndex))
		XCTAssertEqual(index, list.endIndex)
	}

	func testInitFromSequence() {

		let set: Swift.Set<Int> = [1, 2, 3]
		list = LinkedList<Int>(set)
		XCTAssertTrue(list.contains(1))
		XCTAssertTrue(list.contains(2))
		XCTAssertTrue(list.contains(3))
		XCTAssertEqual(list.count, 3)
	}

	func testInitFromArrayLiteral() {

		list = [1, 2, 3]
		var index = list.startIndex
		for i in 1 ... 3 {
			XCTAssertEqual(list[index], i)
			list.formIndex(after: &index)
		}
		XCTAssertEqual(list.count, 3)
	}

	func testInitFromRepeatedValue() {

		list = LinkedList<Int>(repeating: 5, count: 5)
		var index = list.startIndex
		for _ in 0 ..< 5 {
			XCTAssertEqual(list[index], 5)
			list.formIndex(after: &index)
		}
		XCTAssertEqual(list.count, 5)
	}

	func testAppendContestOf() {
		let list1: LinkedList<Int> = [1, 2, 3, 4, 5, 6, 5, 4, 3, 5, 6]
		list.append(contentsOf: [5, 6])
		XCTAssertTrue(list1 == list)
	}

	func testInsertContentsOfAt1() {

		list = []
		list.insert(contentsOf: [1, 2, 3], at: list.startIndex)

		var index = list.startIndex
		XCTAssertEqual(list[index], 1)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 2)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 3)

		XCTAssertEqual(list.count, 3)
	}

	func testInsertContentsOfAt2() {

		list.insert(contentsOf: [4, 5, 6], at: list.startIndex)

		var index = list.startIndex
		XCTAssertEqual(list[index], 4)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 5)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 6)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 1)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 2)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 3)

		XCTAssertEqual(list.count, 12)
	}

	func testInsertContentsOfAt3() {

		list.insert(contentsOf: [7, 8, 9], at: list.endIndex)

		var index = list.endIndex
		list.formIndex(before: &index)
		XCTAssertEqual(list[index], 9)
		list.formIndex(before: &index)
		XCTAssertEqual(list[index], 8)
		list.formIndex(before: &index)
		XCTAssertEqual(list[index], 7)
		list.formIndex(before: &index)
		XCTAssertEqual(list[index], 3)

		XCTAssertEqual(list.count, 12)
	}

	func testFirstLast() {

		XCTAssertEqual(list.first, 1)
		XCTAssertEqual(list.last, 3)

		let list2 = LinkedList<Int>()

		XCTAssertNil(list2.first)
		XCTAssertNil(list2.last)

	}

	func testAppend() {

		var list = LinkedList<Int>()

		list.append(1)
		list.append(2)

		var index = list.startIndex
		XCTAssertEqual(list[index], 1)

		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 2)
		XCTAssertEqual(list.count, 2)

	}

	func testPopFirst() {

		XCTAssertEqual(list.popFirst(), 1)

		list = []
		XCTAssertNil(list.popFirst())
	}

	func testPopLast() {

		XCTAssertEqual(list.popLast(), 3)

		list = []
		XCTAssertNil(list.popLast())
	}

	func testRemoveFirst() {

		XCTAssertEqual(list.removeFirst(), 1)
		XCTAssertEqual(list.first, 2)
		XCTAssertEqual(list.count, 8)
		XCTAssertNotEqual(list._storage.modCount, 0)
	}

	func testRemoveLast() {

		XCTAssertEqual(list.removeLast(), 3)
		XCTAssertEqual(list.last, 4)
		XCTAssertEqual(list.count, 8)
		XCTAssertNotEqual(list._storage.modCount, 0)
	}

	func testInsertAt1() {

		var index = list.index(list.startIndex, offsetBy: 2)
		list.insert(5, at: index)
		XCTAssertEqual(list.count, 10)

		index = list.index(list.startIndex, offsetBy: 1)
		XCTAssertEqual(list[index], 2)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 5)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 3)
		XCTAssertNotEqual(list._storage.modCount, 0)
	}

	func testInsertAt2() {

		list.insert(9, at: list.endIndex)
		XCTAssertEqual(list.count, 10)

		var index = list.index(list.endIndex, offsetBy: -2)
		XCTAssertEqual(list[index], 3)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 9)
		XCTAssertNotEqual(list._storage.modCount, 0)
	}

	func testRemoveAt1() {

		let count = list.count
		let value = list.first
		XCTAssertEqual(list.remove(at: list.startIndex), value)
		XCTAssertEqual(list.count, count - 1)
	}

	func testRemoveAt2() {

		let count = list.count
		let index = list.index(after: list.startIndex)
		let value = list[index]
		XCTAssertEqual(list.remove(at: index), value)
		XCTAssertEqual(list.count, count - 1)
	}

	func testRemoveAt3() {

		let count = list.count
		let last = list.last
		let index = list.index(before: list.endIndex)
		XCTAssertEqual(list.remove(at: index), last)
		XCTAssertEqual(list.count, count - 1)
	}

	func testRemoveAll() {

		list.removeAll()
		XCTAssertEqual(list.count, 0)
		XCTAssertNotEqual(list._storage.modCount, 0)
		XCTAssertNil(list._storage.first)
		XCTAssertNil(list._storage.last)
	}

	func testRemoveWhere() {

		XCTAssertEqual(list.remove { $0 > 3 }, 4)
		XCTAssertEqual(list.count, 8)

		var index = list.index(list.startIndex, offsetBy: 2)
		XCTAssertEqual(list[index], 3)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 5)
		list.formIndex(after: &index)
		XCTAssertEqual(list[index], 6)
		XCTAssertNotEqual(list._storage.modCount, 0)

		let oldModCount = list._storage.modCount
		XCTAssertNil(list.remove { $0 > 10 })
		XCTAssertEqual(oldModCount, list._storage.modCount)
	}

	func testLastIndexWhere() {

		let index = list.index(list.startIndex, offsetBy: 6)
		XCTAssertEqual(list.lastIndex { $0 > 4 }, index)
		XCTAssertNil(list.lastIndex { $0 < 0 })
	}

	func testLastWhere() {

		XCTAssertEqual(list.last { $0 >= 2 }, 3)
		XCTAssertNil(list.last { $0 > 10 })
	}

	// MARK: - Collection

	func testIsEmpty() {

		XCTAssertFalse(list.isEmpty)
		list = []
		XCTAssertTrue(list.isEmpty)
	}

	func testForIn() {

		var count = 0
		for _ in list {
			count += 1
		}
		XCTAssertEqual(list.count, count)
	}

	func testIndexWhere() {

		XCTAssertEqual(list.index { $0 % 2 == 0 }, list.index(after: list.startIndex))
		XCTAssertNil(list.index { $0 > 10 })
	}

	func testIndexOf() {

		XCTAssertEqual(list.index(of: 3), list.index(list.startIndex, offsetBy: 2))
		XCTAssertNil(list.index(of: 10))
	}

	func testContainsWhere() {

		XCTAssertTrue(list.contains { $0 % 2 == 0 })
		XCTAssertFalse(list.contains { $0 > 10 })
	}

	func testFirstWhere() {

		XCTAssertEqual(list.first { $0 == 2 }, 2)
		XCTAssertNil(list.first { $0 > 10 })
	}

	// MARK: - Collection with Equitable elements

	func testContains() {

		XCTAssertTrue(list.contains(2))
		XCTAssertFalse(list.contains(10))
	}

	// MARK: - Equitable LinkedList

	func testRemoveElement() {

		XCTAssertTrue(list.remove(3))
		XCTAssertEqual(list.count, 8)
		XCTAssertNotEqual(list._storage.modCount, 0)

		let oldModCount = list._storage.modCount
		XCTAssertFalse(list.remove(10))
		XCTAssertEqual(oldModCount, list._storage.modCount)
	}

	func testLastIndexOf() {
		XCTAssertEqual(list.lastIndex(of: 5), list.index(list.endIndex, offsetBy: -3))
		XCTAssertNil(list.lastIndex(of: 21))
	}

	func testEquals() {
		let list1: LinkedList<Int>! = [1, 2, 3, 4, 5, 6, 5, 4, 3]
		XCTAssertTrue(list == list1)
		list.append(1)
		XCTAssertFalse(list == list1)
	}

	// MARK: - RangeReplaceableCollection

	func testRangeSubscript1() {
		let sublist = list[list.startIndex..<list.index(list.startIndex, offsetBy: 2)]
		XCTAssertTrue(sublist == LinkedList<Int>([1, 2]))
	}

	func testRangeSubscript2() {
		let startIndex = list.index(list.startIndex, offsetBy: 2)
		let lastIndex = list.index(startIndex, offsetBy: 2)
		let sublist = list[startIndex..<lastIndex]
		XCTAssertTrue(sublist == LinkedList<Int>([3, 4]))
	}

	func testRangeSubscript3() {
		let lastIndex = list.endIndex
		let startIndex = list.index(lastIndex, offsetBy: -2)
		let sublist = list[startIndex..<lastIndex]
		XCTAssertTrue(sublist == LinkedList<Int>([4, 3]))
	}
}
