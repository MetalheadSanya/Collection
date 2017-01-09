//
//  LinkedList.swift
//  Collection
//
//  Created by Alexander Zalutskiy on 28.12.16.
//  Copyright © 2016 Alexander Zalutskiy. All rights reserved.
//

class Node<Element> {

	var item: Element
	var next: Node<Element>?
	var previous: Node<Element>?

	init(previous: Node<Element>?, item: Element, next: Node<Element>?) {
		self.item = item
		self.next = next
		self.previous = previous
	}

}

public struct LinkedListIndex<Element> {

	internal let collection: LinkedList<Element>
	internal let modCount: UInt
	internal let node: Node<Element>?

	internal init(collection: LinkedList<Element>, modCount: UInt,
	              node: Node<Element>?) {
		self.collection = collection
		self.modCount = modCount
		self.node = node
	}

	internal var isValid: Bool {
		return modCount == collection.modCount
	}
}

extension LinkedListIndex: Equatable {
}

public func ==<Element>(lhs: LinkedListIndex<Element>,
                        rhs: LinkedListIndex<Element>) -> Bool {

	precondition(lhs.collection === rhs.collection,
	             "Indexes of the different collections",
	             file: #file,
	             line: #line)
	precondition(lhs.isValid,
	             "The collection has changed",
	             file: #file,
	             line: #line)
	precondition(rhs.isValid,
	             "The collection has changed",
	             file: #file,
	             line: #line)
	return lhs.node === rhs.node || (lhs.node == nil && rhs.node == nil)
}

extension LinkedListIndex: Comparable {
}

public func ><Element>(lhs: LinkedListIndex<Element>,
                       rhs: LinkedListIndex<Element>) -> Bool {

	precondition(lhs.collection === rhs.collection,
	             "Indexes of the different collections",
	             file: #file,
	             line: #line)
	precondition(lhs.isValid,
	             "The collection has changed",
	             file: #file,
	             line: #line)
	precondition(rhs.isValid,
	             "The collection has changed",
	             file: #file,
	             line: #line)
	guard lhs != rhs else { return false }
	guard rhs != rhs.collection.endIndex else { return false }
	guard lhs != lhs.collection.endIndex else { return true }

	let collection = lhs.collection

	var rhs = rhs
	while rhs != collection.endIndex {
		collection.formIndex(after: &rhs)
		if rhs == lhs { return true }
	}
	return false
}

public func <<Element>(lhs: LinkedListIndex<Element>,
                       rhs: LinkedListIndex<Element>) -> Bool {

	precondition(lhs.collection === rhs.collection,
	             "Indexes of the different collections",
	             file: #file,
	             line: #line)
	precondition(lhs.isValid,
	             "The collection has changed",
	             file: #file,
	             line: #line)
	precondition(rhs.isValid,
	             "The collection has changed",
	             file: #file,
	             line: #line)
	guard lhs != rhs else { return false }
	guard rhs != rhs.collection.endIndex else { return true }
	guard lhs != lhs.collection.endIndex else { return false }

	let collection = lhs.collection

	var lhs = lhs
	while lhs != collection.endIndex {
		collection.formIndex(after: &lhs)
		if rhs == lhs { return true }
	}
	return false
}

open class LinkedList<Element>:
	Swift.Collection,
	Swift.MutableCollection,
	Swift.BidirectionalCollection,
	Swift.ExpressibleByArrayLiteral,
	Swift.RangeReplaceableCollection {

	public typealias Index = LinkedListIndex<Element>

	public typealias IndexDistance = Int

	public typealias SubSequence = LinkedList<Element>

	/// The number of elements in the list.
	public // @testable
	private(set) var count: Int = 0

	/// Pointer to first node.
	internal var firstNode: Node<Element>?

	/// Pointer to last node.
	internal var lastNode: Node<Element>?

	internal // @testable
	var modCount: UInt = 0

	/// Creates a new, empty list
	///
	/// This is equivalent to initializing with an empty array literal.
	/// For example:
	///
	///     var emptyList = LinkedList<Int>()
	///     print(emptyList.isEmpty)
	///     // Prints "true"
	///
	///     emptyList = []
	///     print(emptyList.isEmpty)
	///     // Prints "true"
	required public // @testable
	init() {
	}


	// MARK: - IndexableBase


	/// The list's "past the end" position---that is, the position one greater
	/// than the last valid subscript argument.
	///
	/// When you need a range that includes the last element of a list, use
	/// the half-open range operator (`..<`) with `endIndex`. The `..<` operator
	/// creates a range that doesn't include the upper bound, so it's always
	/// safe to use with `endIndex`. For example:
	///
	///     let numbers: LinkedList<Int> = [10, 20, 30, 40, 50]
	///     if let index = numbers.index(of: 30) {
	///         print(numbers[index ..< numbers.endIndex])
	///     }
	///     // Prints "[30, 40, 50]"
	///
	/// If the list is empty, `endIndex` is equal to `startIndex`.
	public var endIndex: Index {
		return index(for: nil)
	}

	/// The position of the first element in a nonempty list.
	///
	/// If the collection is empty, `startIndex` is equal to `endIndex`.
	public var startIndex: Index {
		return index(for: firstNode)
	}

	/// Returns the position immediately after the given index.
	///
	/// - Parameter i: A valid index of the list. `i` must be less than
	///   `endIndex`.
	/// - Returns: The index value immediately after `i`.
	public // @testable
	func index(after i: Index) -> Index {

		precondition(validateIndex(i),
		             "The index of the other collection or the collection has changes",
		             file: #file,
		             line: #line)
		precondition(i != endIndex,
		             "The index equal to endIndex",
		             file: #file,
		             line: #line)
		return index(for: i.node!.next)
	}

	/// Replaces the given index with its successor.
	///
	/// - Parameter i: A valid index of the list. `i` must be less than
	///    `endIndex`.
	public // @testable
	func formIndex(after i: inout Index) {

		i = index(after: i)
	}

	/// Accesses the element at the specified position.
	///
	/// For example, you can replace an element of an list by using its
	/// subscript.
	///
	///     var streets: LinkedList<String> = ["Adams", "Bryant", "Channing"]
	///     streets[1] = "Butler"
	///     print(streets[1])
	///     // Prints "Butler"
	///
	/// You can subscript a list with any valid index other than the list's end
	/// index. The end index refers to the position one past the last element of
	/// a list, so it doesn't correspond with an element.
	///
	/// - Parameter position: The position of the element to access. `position`
	///   must be a valid index of the collection that is not equal to the
	///   `endIndex` property.
	public // @testable
	subscript(position: Index) -> Element {
		get {
			precondition(validateIndex(position),
			             "The index of the other collection or the collection has changes",
			             file: #file,
			             line: #line)
			precondition(position != endIndex,
			             "The index equal to endIndex",
			             file: #file,
			             line: #line)
			return position.node!.item
		}
		set(newValue) {
			precondition(validateIndex(position),
			             "The index of the other collection or the collection has changes",
			             file: #file,
			             line: #line)
			precondition(position != endIndex,
			             "The index equal to endIndex",
			             file: #file,
			             line: #line)
			position.node!.item = newValue
		}
	}

	// TODO: docs

	public // @testable (get only)
	subscript(bounds: Range<Index>) -> SubSequence {
		get {
			precondition(validateIndex(bounds.lowerBound),
			             "The lower index of the other collection or the collection has changes",
			             file: #file,
			             line: #line)
			precondition(validateIndex(bounds.upperBound),
			             "The upper index of the other collection or the collection has changes",
			             file: #file,
			             line: #line)

			let list = LinkedList<Element>()
			var lowerBounds = bounds.lowerBound
			while lowerBounds.node !== bounds.upperBound.node {
				if let node = lowerBounds.node {
					list.append(node.item)
				}
				formIndex(after: &lowerBounds)
			}
			return list
		}
		// TODO: Implementation
		// TODO: tests
		set(newValue) {

		}
	}

	// MARK: - BidirectionalIndexable

	/// Returns the position immediately before the given index.
	///
	/// - Parameter i: A valid index of the collection. `i` must be greater than
	///   `startIndex`.
	/// - Returns: The index value immediately before `i`.
	public // @testable
	func index(before i: Index) -> Index {

		precondition(validateIndex(i),
		             "The index of the other collection or the collection has changes",
		             file: #file,
		             line: #line)
		guard i.node != nil else { return index(for: lastNode) }
		precondition(i != startIndex,
		             "The index equal to startIndex",
		             file: #file,
		             line: #line)
		return index(for: i.node!.previous)
	}

	// Replaces the given index with its predecessor.
	///
	/// - Parameter i: A valid index of the collection. `i` must be greater than
	///   `startIndex`.
	public // @testable
	func formIndex(before i: inout Index) {

		i = index(before: i)
	}

	// MARK: - Indexable

	/// Returns the distance between two indices.
	///
	/// `start` index must be less than or equal to `end`.
	///
	/// - Parameters:
	///   - start: A valid index of the collection.
	///   - end: Another valid index of the collection. If `end` is equal to
	///     `start`, the result is zero.
	/// - Returns: The distance between `start` and `end`.
	///
	/// - Complexity: O(*n*), where *n* is the resulting distance.
	public // @testable
	func distance(from start: Index, to end: Index) -> IndexDistance {

		precondition(validateIndex(start),
		             "The index of the other collection or the collection has changes",
		             file: #file,
		             line: #line)
		precondition(validateIndex(end),
		             "The index of the other collection or the collection has changes",
		             file: #file,
		             line: #line)

		guard start != end else { return 0 }

		var distance = 0
		var start = start

		while start != end {
			formIndex(after: &start)
			distance += 1
		}
		return distance
	}

	/// Returns an index that is the specified distance from the given index.
	///
	/// The following example obtains an index advanced four positions from a
	/// string's starting index and then prints the character at that position.
	///
	///     let s = "Swift"
	///     let i = s.index(s.startIndex, offsetBy: 4)
	///     print(s[i])
	///     // Prints "t"
	///
	/// The value passed as `n` must not offset `i` beyond the `endIndex` or
	/// before the `startIndex` of this collection.
	///
	/// - Parameters:
	///   - i: A valid index of the collection.
	///   - n: The distance to offset `i`. `n` must not be negative unless the
	///     collection conforms to the `BidirectionalCollection` protocol.
	/// - Returns: An index offset by `n` from the index `i`. If `n` is positive,
	///   this is the same value as the result of `n` calls to `index(after:)`.
	///   If `n` is negative, this is the same value as the result of `-n` calls
	///   to `index(before:)`.
	///
	/// - SeeAlso: `index(_:offsetBy:limitedBy:)`, `formIndex(_:offsetBy:)`
	/// - Complexity: O(*n*), where *n* is the absolute
	///   value of `n`.
	public // @testable
	func index(_ i: Index, offsetBy n: IndexDistance) -> Index {

		precondition(validateIndex(i),
		             "The index of the other collection or the collection has changes",
		             file: #file,
		             line: #line)

		var i = i
		let counter = abs(n)
		for _ in 0 ..< counter {
			if n > 0 {
				formIndex(after: &i)
			}
			else {
				formIndex(before: &i)
			}
		}
		return i
	}


	/// Offsets the given index by the specified distance.
	///
	/// The value passed as `n` must not offset `i` beyond the `endIndex` or
	/// before the `startIndex` of this collection.
	///
	/// - Parameters:
	///   - i: A valid index of the collection.
	///   - n: The distance to offset `i`.
	///
	/// - SeeAlso: `index(_:offsetBy:)`, `formIndex(_:offsetBy:limitedBy:)`
	/// - Complexity: O(*n*), where *n* is the absolute value of `n`.
	public // @testable
	func formIndex(_ i: inout Index, offsetBy n: IndexDistance) {

		i = index(i, offsetBy: n)
	}

	/// Returns an index that is the specified distance from the given index,
	/// unless that distance is beyond a given limiting index.
	///
	/// The following example obtains an index advanced four positions from a
	/// string's starting index and then prints the character at that position.
	/// The operation doesn't require going beyond the limiting `s.endIndex`
	/// value, so it succeeds.
	///
	///     let s = "Swift"
	///     if let i = s.index(s.startIndex, offsetBy: 4, limitedBy: s.endIndex) {
	///         print(s[i])
	///     }
	///     // Prints "t"
	///
	/// The next example attempts to retrieve an index six positions from
	/// `s.startIndex` but fails, because that distance is beyond the index
	/// passed as `limit`.
	///
	///     let j = s.index(s.startIndex, offsetBy: 6, limitedBy: s.endIndex)
	///     print(j)
	///     // Prints "nil"
	///
	/// The value passed as `n` must not offset `i` beyond the `endIndex` or
	/// before the `startIndex` of this collection, unless the index passed as
	/// `limit` prevents offsetting beyond those bounds.
	///
	/// - Parameters:
	///   - i: A valid index of the collection.
	///   - n: The distance to offset `i`.
	///   - limit: A valid index of the collection to use as a limit. If `n > 0`,
	///     a limit that is less than `i` has no effect. Likewise, if `n < 0`, a
	///     limit that is greater than `i` has no effect.
	/// - Returns: An index offset by `n` from the index `i`, unless that index
	///   would be beyond `limit` in the direction of movement. In that case,
	///   the method returns `nil`.
	///
	/// - SeeAlso: `index(_:offsetBy:)`, `formIndex(_:offsetBy:limitedBy:)`
	/// - Complexity: O(*n*), where *n* is the absolute value of `n`.
	public // @testable
	func index(_ i: Index,
	           offsetBy n: IndexDistance,
	           limitedBy limit: Index) -> Index? {

		precondition(validateIndex(i),
		             "The index of the other collection or the collection has changes",
		             file: #file,
		             line: #line)
		precondition(validateIndex(limit),
		             "The index of the other collection or the collection has changes",
		             file: #file,
		             line: #line)

		guard i != limit else { return nil }
		guard n != 0 else { return i }

		var i = i
		let counter = abs(n)
		for _ in 0 ..< counter {
			if n > 0 {
				formIndex(after: &i)
			}
			else {
				formIndex(before: &i)
			}
			guard i != limit else { return nil }
		}
		return i
	}

	/// Offsets the given index by the specified distance, or so that it equals
	/// the given limiting index.
	///
	/// The value passed as `n` must not offset `i` beyond the `endIndex` or
	/// before the `startIndex` of this collection, unless the index passed as
	/// `limit` prevents offsetting beyond those bounds.
	///
	/// - Parameters:
	///   - i: A valid index of the collection.
	///   - n: The distance to offset `i`. `n` must not be negative unless the
	///     collection conforms to the `BidirectionalCollection` protocol.
	/// - Returns: `true` if `i` has been offset by exactly `n` steps without
	///   going beyond `limit`; otherwise, `false`. When the return value is
	///   `false`, the value of `i` is equal to `limit`.
	///
	/// - SeeAlso: `index(_:offsetBy:)`, `formIndex(_:offsetBy:limitedBy:)`
	/// - Complexity: O(*n*), where *n* is the absolute value of `n`.
	public // @testable
	func formIndex(_ i: inout Index,
	               offsetBy n: IndexDistance,
	               limitedBy limit: Index) -> Bool {

		i = index(i, offsetBy: n, limitedBy: limit) ?? limit
		return i != limit
	}

	// MARK: - Initializers

	/// Creates an list containing the elements of a sequence.
	///
	/// You can use this initializer to create an list from any other type that
	/// conforms to the `Sequence` protocol. For example, you might want to
	/// create an list with the integers from 1 through 7. Use this initializer
	/// around a range instead of typing all those numbers in an array literal.
	///
	///     let numbers = LinkedList(1...7)
	///     print(numbers)
	///     // Prints "LinkedList([1, 2, 3, 4, 5, 6, 7])"
	///
	/// You can also use this initializer to convert a complex sequence or
	/// collection type back to an list. For example, the `keys` property of
	/// a dictionary isn't an list with its own storage, it's a collection
	/// that maps its elements from the dictionary only when they're
	/// accessed, saving the time and space needed to allocate an list. If
	/// you need to pass those keys to a method that takes an list, however,
	/// use this initializer to convert that collection from its type of
	/// `LazyMapCollection<Dictionary<String, Int>, Int>` to a simple
	/// `LinkedList<String>`.
	///
	///     func cacheImagesWithNames(names: LinkedList<String>) {
	///         // custom image loading and caching
	///      }
	///
	///     let namedHues: [String: Int] = ["Vermillion": 18, "Magenta": 302,
	///             "Gold": 50, "Cerise": 320]
	///     let colorNames = LinkedList(namedHues.keys)
	///     cacheImagesWithNames(colorNames)
	///
	///     print(colorNames)
	///     // Prints "LinkedList(["Gold", "Cerise", "Magenta", "Vermillion"])"
	///
	/// - Parameter elements: The sequence of elements to turn into an list.
	required public // @testable
	convenience init<S:Sequence>(_ elements: S)
		where
		S.Iterator.Element == Element {
		self.init()
		append(contentsOf: elements)
	}

	/// Creates an list from the given array literal.
	///
	/// Do not call this initializer directly. It is used by the compiler when
	/// you use an array literal. Instead, create a new list by using an array
	/// literal as its value. To do this, enclose a comma-separated list of
	/// values in square brackets.
	///
	/// Here, an list of strings is created from an array literal holding only
	/// strings:
	///
	///     let ingredients: LinkedList<String> =
	///           ["cocoa beans", "sugar", "cocoa butter", "salt"]
	///
	/// - Parameter elements: A variadic list of elements of the new list.
	required public // @testable
	convenience init(arrayLiteral elements: Element...) {
		self.init(elements)
	}

	/// Creates a new list containing the specified number of a single, repeated
	/// value.
	///
	/// Here's an example of creating an list initialized with five strings
	/// containing the letter *Z*.
	///
	///     let fiveZs = LinkedList(repeating: "Z", count: 5)
	///     print(fiveZs)
	///     // Prints "LinkedList(["Z", "Z", "Z", "Z", "Z"])"
	///
	/// - Parameters:
	///   - repeatedValue: The element to repeat.
	///   - count: The number of times to repeat the value passed in the
	///     `repeating` parameter. `count` must be zero or greater.
	required public // @testable
	convenience init(repeating repeatedValue: Element,
	                 count: Int) {
		self.init((0 ..< count).map { _ in repeatedValue })
	}

	/// Adds the elements of a sequence to the end of this list.
	///
	/// The following example appends the elements of a `Range<Int>` instance to
	/// an list of integers:
	///
	///     var numbers: LinkedList<Int> = [1, 2, 3, 4, 5]
	///     numbers.append(contentsOf: 10...15)
	///     print(numbers)
	///     // Prints "LinkedList([1, 2, 3, 4, 5, 10, 11, 12, 13, 14, 15])"
	///
	/// - Parameter newElements: The elements to append to the list.
	///
	/// - Complexity: O(*n*), where *n* is the length of the `newElements`
	///   sequence.
	public // @testable
	func append<S:Sequence>(contentsOf newElements: S)
		where
		S.Iterator.Element == Element {

		insert(contentsOf: newElements, at: endIndex)
	}

	/// Inserts the elements of a sequence into the list at the specified
	/// position.
	///
	/// The new elements are inserted before the element currently at the
	/// specified index. If you pass the list's `endIndex` property as the
	/// `i` parameter, the new elements are appended to the list.
	///
	/// Here's an example of inserting a range of integers into an list of the
	/// same type:
	///
	///     var numbers: LinkedList<Int> = [1, 2, 3, 4, 5]
	///     numbers.insert(contentsOf: 100...103, at: 3)
	///     print(numbers)
	///     // Prints "LinkedList([1, 2, 3, 100, 101, 102, 103, 4, 5])"
	///
	/// Calling this method may invalidate any existing indices for use with this
	/// collection.
	///
	/// - Parameter newElements: The new elements to insert into the collection.
	/// - Parameter i: The position at which to insert the new elements. `i` must
	///   be a valid index of the collection.
	///
	/// - Complexity: O(*m*), where *m* is the combined length of the collection
	///   and `newElements`. If `i` is equal to the collection's `endIndex`
	///   property, the complexity is O(*n*), where *n* is the length of
	///   `newElements`.
	public func insert<S:Sequence>(contentsOf newElements: S,
	                               at i: Index)
		where
		S.Iterator.Element == Element {

		precondition(validateIndex(i),
		             "The index of the other collection or the collection has changes",
		             file: #file,
		             line: #line)

		let succ: Node<Element>?
		var pred: Node<Element>?

		if i == endIndex {
			succ = nil
			pred = lastNode
		}
		else {
			succ = i.node
			pred = succ?.previous
		}

		var fromSize = 0

		for obj in newElements {
			fromSize += 1

			let newNode = Node(previous: pred, item: obj, next: nil)
			if pred == nil {
				firstNode = newNode
			}
			pred?.next = newNode
			pred = newNode
		}

		if fromSize == 0 {
			return
		}

		if succ == nil {
			lastNode = pred
		}
		else {
			pred?.next = succ
			succ?.previous = pred
		}

		count += fromSize
		modCount += 1
	}

	/// Adds an element to the end of the list.
	///
	/// The following example adds a new number to an list of integers:
	///
	///     var numbers: LinkedList<Int> = [1, 2, 3, 4, 5]
	///     numbers.append(100)
	///
	///     print(numbers)
	///     // Prints "LinkedList([1, 2, 3, 4, 5, 100])"
	///
	/// - Parameter newElement: The element to append to the list.
	///
	/// - Complexity: O(1).
	public // @testable
	func append(_ newElement: Element) {

		linkLast(newElement)
	}

	/// The first element of the list.
	///
	/// If the list is empty, the value of this property is `nil`.
	///
	///     let numbers: LinkedList<Int> = [10, 20, 30, 40, 50]
	///     if let firstNumber = numbers.first {
	///         print(firstNumber)
	///     }
	///     // Prints "10"
	public // @testable
	var first: Element? {
		return firstNode?.item
	}

	/// The last element of the list.
	///
	/// If the list is empty, the value of this property is `nil`.
	///
	///     let numbers: LinkedList<Int> = [10, 20, 30, 40, 50]
	///     if let lastNumber = numbers.last {
	///         print(lastNumber)
	///     }
	///     // Prints "50"
	public // @testable
	var last: Element? {
		return lastNode?.item
	}

	/// Removes and returns the first element of the list.
	///
	/// - Returns: The first element of the list if the list is not empty;
	///    otherwise, `nil`.
	///
	/// - Complexity: O(1)
	/// - SeeAlso: `removeFirst()`
	@discardableResult public // @testable
	func popFirst() -> Element? {

		guard let node = firstNode else { return nil }
		return unlinkFirst(node)
	}

	/// Removes and returns the last element of the list.
	///
	/// - Returns: The last element of the list if the list has one or more
	///    elements; otherwise, `nil`.
	///
	/// - Complexity: O(1).
	/// - SeeAlso: `removeLast()`
	@discardableResult public // @testable
	func popLast() -> Element? {

		guard let node = lastNode else { return nil }
		return unlinkLast(node)
	}

	/// Removes and returns the first element of the list.
	///
	/// The list must not be empty.
	///
	/// - Returns: The first element of the list.
	///
	/// - Complexity: O(1)
	/// - SeeAlso: `popFirst()`
	@discardableResult public // @testable
	func removeFirst() -> Element {

		precondition(count != 0,
		             "Empty collection",
		             file: #file,
		             line: #line)
		return popFirst()!
	}

	/// Removes and returns the last element of the list.
	///
	/// The list must not be empty.
	///
	/// - Returns: The last element of the list.
	///
	/// - Complexity: O(1)
	/// - SeeAlso: `popLast()`
	@discardableResult public // @testable
	func removeLast() -> Element {

		precondition(count != 0,
		             "Empty collection",
		             file: #file,
		             line: #line)
		return popLast()!
	}

	/// Inserts a new element into the list at the specified position.
	///
	/// The new element is inserted before the element currently at the specified
	/// index. If you pass the list's `endIndex` property as the `i`
	/// parameter, the new element is appended to the list.
	///
	///     var numbers: LinkedList<Int> = [1, 2, 3, 4, 5]
	///     numbers.insert(100, at: 3)
	///     numbers.insert(200, at: numbers.endIndex)
	///
	///     print(numbers)
	///     // Prints "LinkedList([1, 2, 3, 100, 4, 5, 200])"
	///
	/// Calling this method may invalidate any existing indices for use with this
	/// list.
	///
	/// - Parameter newElement: The new element to insert into the list.
	/// - Parameter i: The position at which to insert the new element. `i` must
	///   be a valid index into the list.
	///
	/// - Complexity: O(1)
	public // @testable
	func insert(_ newElement: Element, at i: Index) {

		precondition(validateIndex(i),
		             "The index of the other collection or the collection has changes",
		             file: #file,
		             line: #line)
		if i == endIndex {
			linkLast(newElement)
		}
		else {
			link(newElement, before: i.node!)
		}
	}

	/// Removes and returns the element at the specified position.
	///
	/// All the elements following the specified position are moved to close the
	/// gap. This example removes the middle element from an list of
	/// measurements.
	///
	///     var measurements: LinkedList<Float> = [1.2, 1.5, 2.9, 1.2, 1.6]
	///     let removed = measurements.remove(at: 2)
	///     print(measurements)
	///     // Prints "LinkedList([1.2, 1.5, 1.2, 1.6])"
	///
	/// Calling this method may invalidate any existing indices for use with this
	/// collection.
	///
	/// - Parameter i: The position of the element to remove. `i` must be a valid
	///   index of the list that is not equal to the collection's end
	///   index.
	/// - Returns: The removed element.
	///
	/// - Complexity: O(1)
	@discardableResult public // @testable
	func remove(at index: Index) -> Element {

		precondition(validateIndex(index),
		             "The index of the other collection or the collection has changes",
		             file: #file,
		             line: #line)
		return unlink(index.node!)
	}

	/// Removes all elements from the collection.
	///
	/// Calling this method may invalidate any existing indices for use with this
	/// collection.
	///
	/// - Complexity: O(*n*), where *n* is the length of the collection.
	public // @testable
	func removeAll() {

		var node = firstNode
		for _ in 0 ..< count {
			let next = node?.next
			node?.next = nil
			node?.previous = nil
			node = next
		}
		firstNode = nil
		lastNode = nil
		count = 0
		modCount += 1
	}

	// TODO: docs
	@discardableResult public // @testable
	func remove(
		where predicate: (Element) throws -> Bool) rethrows -> Element? {

		var node = firstNode
		for _ in 0 ..< count {
			if let node = node, try predicate(node.item) {
				return unlink(node)
			}
			node = node?.next
		}
		return nil
	}

	/// Returns the last index in which an element of the list satisfies the
	/// given predicate.
	///
	/// You can use the predicate to find an element of a type that doesn't
	/// conform to the `Equatable` protocol or to find an element that matches
	/// particular criteria. Here's an example that finds a student name that
	/// begins with the letter "A":
	///
	///     let students: LinkedList<Int> = ["Kofi", "Abena", "Peter", "Akosua"]
	///     if let i = students.index(where: { $0.hasPrefix("A") }) {
	///         print("\(students[i]) starts with 'A'!")
	///     }
	///     // Prints "Akosua starts with 'A'!"
	///
	/// - Parameter predicate: A closure that takes an element as its argument
	///   and returns a Boolean value that indicates whether the passed element
	///   represents a match.
	/// - Returns: The index of the last element for which `predicate` returns
	///   `true`. If no elements in the list satisfy the given predicate,
	///   returns `nil`.
	///
	/// - SeeAlso: `lastIndex(of:)`
	public // @testable
	func lastIndex(
		where predicate: (Iterator.Element) throws -> Bool) rethrows -> Index? {

		var node = lastNode
		for _ in 0 ..< count {
			if let item = node?.item, try predicate(item) {
				return index(for: node)
			}
			node = node?.previous
		}
		return nil
	}


	/// Returns the last element of the list that satisfies the given
	/// predicate or nil if no such element is found.
	///
	/// - Parameter predicate: A closure that takes an element of the
	///   list as its argument and returns a Boolean value indicating
	///   whether the element is a match.
	/// - Returns: The first match or `nil` if there was no match.
	public // @testable
	func last(
		where predicate: (Element) throws -> Bool) rethrows -> Element? {

		var node = lastNode
		for _ in 0 ..< count {
			if let item = node?.item, try predicate(item) {
				return item
			}
			node = node?.previous
		}
		return nil
	}

	// TODO: implementation
	// TODO: docs
	// TODO: tests
	public func replaceSubrange<C>(_ subrange: Range<Index>,
	                               with newElements: C)
		where
		C: Swift.Collection,
		C.Iterator.Element == Iterator.Element {

		// TODO: prereq

		var firstNode = subrange.lowerBound.node
		let lastNode = subrange.upperBound.node

		while firstNode !== lastNode {
			firstNode = firstNode?.next
			if let node = firstNode?.previous {
				unlink(node)
			}
		}

		//z
		//		else {
		//			insert
		//		}

	}

	internal func index(for node: Node<Element>?) -> LinkedListIndex<Element> {

		return LinkedListIndex(collection: self, modCount: modCount, node: node)
	}

	internal func validateIndex(_ index: Index) -> Bool {

		return index.collection === self && index.isValid
	}

	internal func isPositionIndex(_ index: Int) -> Bool {

		return (0 ... count).contains(index)
	}

	internal func checkPositionIndex(_ index: Int) {

		if !isPositionIndex(index) {
			fatalError("Index out of bounds")
		}
	}

	internal func node(at index: Int) -> Node<Element>? {

		if index < (count >> 1) {
			guard var node = firstNode else { return nil }
			for _ in 0 ..< index {
				node = node.next!
			}
			return node
		}
		else {
			guard var node = lastNode else { return nil }
			for _ in 0 ..< (count - index - 1) {
				node = node.previous!
			}
			return node
		}
	}

	internal func linkLast(_ newElement: Element) {

		let l = lastNode
		let newNode = Node(previous: l, item: newElement, next: nil)
		lastNode = newNode
		if l == nil {
			firstNode = newNode
		}
		l?.next = newNode
		count += 1
		modCount += 1
	}

	internal func linkFirst(_ newElement: Element) {

		let f = firstNode
		let newNode = Node(previous: nil, item: newElement, next: f)
		firstNode = newNode
		if f == nil {
			lastNode = newNode
		}
		f?.previous = newNode
		count += 1
		modCount += 1
	}

	internal func link(_ newElement: Element, before node: Node<Element>) {

		let pred = node.previous
		let newNode = Node(previous: pred, item: newElement, next: node)
		node.previous = newNode
		if pred == nil {
			firstNode = newNode
		}
		pred?.next = newNode
		count += 1
		modCount += 1
	}

	internal func unlinkFirst(_ node: Node<Element>) -> Element {

		let element = node.item
		let next = node.next
		firstNode = next
		if next == nil {
			lastNode = nil
		}
		next?.previous = nil
		count -= 1
		modCount += 1
		return element
	}

	internal func unlinkLast(_ node: Node<Element>) -> Element {

		let element = node.item
		let prev = node.previous
		lastNode = prev
		if prev == nil {
			firstNode = nil
		}
		prev?.next = nil
		count -= 1
		modCount += 1
		return element
	}

	@discardableResult internal func unlink(_ node: Node<Element>) -> Element {

		let element = node.item
		let next = node.next
		let prev = node.previous

		if prev == nil {
			firstNode = next
		}
		prev?.next = next
		if next == nil {
			lastNode = prev
		}
		next?.previous = prev

		count -= 1
		modCount += 1
		return element
	}

}

public extension LinkedList
	where Element: Swift.Equatable {

	// TODO: docs
	public // @testable
	func remove(_ element: LinkedList.Iterator.Element) -> Bool {

		return remove { $0 == element } != nil
	}

	// TODO: docs
	public // @testable
	func lastIndex(
		of element: LinkedList.Iterator.Element) -> LinkedList.Index? {

		return lastIndex { $0 == element }
	}

}

extension LinkedList: Swift.CustomStringConvertible,
	Swift.CustomDebugStringConvertible {

	internal func makeDescription(isDebug: Bool) -> String {

		var result = "LinkedList(["
		var first = true
		for item in self {
			if first {
				first = false
			}
			else {
				result += ", "
			}
			debugPrint(item, terminator: "", to: &result)
		}

		result += "])"
		return result
	}

	/// A textual representation of the array and its elements.
	public var description: String {
		return makeDescription(isDebug: false)
	}

	/// A textual representation of the array and its elements, suitable for
	/// debugging.
	public var debugDescription: String {
		return makeDescription(isDebug: true)
	}

}

// TODO: docs
public // @testable
func ==<Element:Equatable>(lhs: LinkedList<Element>,
                           rhs: LinkedList<Element>) -> Bool {

	guard lhs.count == rhs.count else { return false }
	var li = lhs.startIndex
	var ri = rhs.startIndex
	while li != lhs.endIndex {
		if li.node?.item != ri.node?.item { return false }
		lhs.formIndex(after: &li)
		rhs.formIndex(after: &ri)
	}
	return true
}