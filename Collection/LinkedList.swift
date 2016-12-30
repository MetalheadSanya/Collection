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

open class LinkedListIterator<Element>: Swift.IteratorProtocol {

	private var node: Node<Element>?

	init(node: Node<Element>?) {
		self.node = node
	}

	public func next() -> Element? {
		let item = node?.item
		node = node?.next
		return item
	}

}

open class LinkedList<Element>: Swift.MutableCollection,
	Swift.ExpressibleByArrayLiteral, Swift.RangeReplaceableCollection/*,
	Swift.BidirectionalCollection*/ {

	public typealias Index = Int

	public typealias Iterator = LinkedListIterator<Element>

	/// The number of elements in the list.
	public private(set) var count: Int = 0

	/// Pointer to first node.
	internal var firstNode: Node<Element>?

	/// Pointer to last node.
	internal var lastNode: Node<Element>?

	internal var modCount: Int = 0

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
	required public init() {
	}

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
	required public convenience init<S:Sequence>(_ elements: S)
		where S.Iterator.Element == Element {
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
	required public convenience init(arrayLiteral elements: Element...) {
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
	required public convenience init(repeating repeatedValue: Iterator.Element,
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
	/// sequence.
	public func append<S:Sequence>(contentsOf newElements: S)
		where S.Iterator.Element == Element {
		insert(contentsOf: newElements, at: count)
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
		where S.Iterator.Element == Element {

		checkPositionIndex(i)

		let succ: Node<Element>?
		var pred: Node<Element>?

		if i == count {
			succ = nil
			pred = lastNode
		}
		else {
			succ = node(at: i)
			pred = succ?.previous
		}

		var fromSize = 0

		for obj in newElements {
			fromSize += 1

			let newNode = Node(previous: pred, item: obj, next: nil)
			if pred == nil {
				firstNode = newNode
			}
			else {
				pred?.next = newNode
			}
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
	public func append(_ newElement: Element) {
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
	public var first: Element? {
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
	public var last: Element? {
		return lastNode?.item
	}

	/// The position of the first element in a nonempty list.
	///
	/// If the collection is empty, `startIndex` is equal to `endIndex`.
	public var startIndex: Index {
		return count == 0 ? endIndex : 0
	}

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
		return count
	}

	/// Returns the position immediately after the given index.
	///
	/// - Parameter i: A valid index of the list. `i` must be less than
	///   `endIndex`.
	/// - Returns: The index value immediately after `i`.
	public func index(after i: Index) -> Index {
		checkPositionIndex(i + 1)
		return i + 1
	}

	/// Returns the position immediately before the given index.
	///
	/// - Parameter i: A valid index of the collection. `i` must be greater than
	///   `startIndex`.
	/// - Returns: The index value immediately before `i`.
	public func index(before i: Index) -> Index {
		checkPositionIndex(i - 1)
		return i - 1
	}

	/// Replaces the given index with its successor.
	///
	/// - Parameter i: A valid index of the list. `i` must be less than
	///    `endIndex`.
	public func formIndex(after i: inout Index) {
		i = index(after: i)
	}

	/// Replaces the given index with its predecessor.
	///
	/// - Parameter i: A valid index of the collection. `i` must be greater than
	///   `startIndex`.
	public func formIndex(before i: inout Index) {
		i = index(before: i)
	}


	/// Returns an iterator over the elements of the list.
	public func makeIterator() -> Iterator {
		return LinkedListIterator(node: firstNode)
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
	public subscript(position: Index) -> Element {
		get {
			checkPositionIndex(position)
			return node(at: position)!.item
		}
		set(newValue) {
			checkPositionIndex(position)
			node(at: position)?.item = newValue
		}
	}

	/*public subscript(bounds: Range<Index>) -> SubSequence {
		get {
			return []
		}
		set(newValue) {

		}
	}*/

	/// Removes and returns the first element of the list.
	///
	/// - Returns: The first element of the list if the list is not empty;
	///    otherwise, `nil`.
	///
	/// - Complexity: O(1)
	/// - SeeAlso: `removeFirst()`
	@discardableResult public func popFirst() -> Element? {
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
	@discardableResult public func popLast() -> Element? {
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
	@discardableResult public func removeFirst() -> Element {
		guard let element = popFirst() else {
			fatalError("No such element")
		}
		return element
	}

	/// Removes and returns the last element of the list.
	///
	/// The list must not be empty.
	///
	/// - Returns: The last element of the list.
	///
	/// - Complexity: O(1)
	/// - SeeAlso: `popLast()`
	@discardableResult public func removeLast() -> Element {
		guard let element = popLast() else {
			fatalError("No such element")
		}
		return element
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
	/// - Complexity: O(*n*), where *n* is the length of the collection.
	public func insert(_ newElement: Element, at i: Index) {
		checkPositionIndex(i)
		if i == count {
			linkLast(newElement)
		}
		else {
			link(newElement, before: node(at: i)!)
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
	/// - Complexity: O(*n*), where *n* is the length of the collection.
	@discardableResult public func remove(at index: Index) -> Element {
		checkPositionIndex(index)
		return unlink(node(at: index)!)
	}

	/// Removes all elements from the collection.
	///
	/// Calling this method may invalidate any existing indices for use with this
	/// collection.
	///
	/// - Complexity: O(*n*), where *n* is the length of the collection.
	public func removeAll() {
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

	@discardableResult public func remove(
		where predicate: (Iterator.Element) throws -> Bool) rethrows -> Iterator.Element? {
		var node = firstNode
		for _ in 0 ..< count {
			if let node = node, try predicate(node.item) {
				return unlink(node)
			}
			node = node?.next
		}
		return nil
	}

	/// Returns the first index in which an element of the list satisfies the
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
	///     // Prints "Abena starts with 'A'!"
	///
	/// - Parameter predicate: A closure that takes an element as its argument
	///   and returns a Boolean value that indicates whether the passed element
	///   represents a match.
	/// - Returns: The index of the first element for which `predicate` returns
	///   `true`. If no elements in the list satisfy the given predicate,
	///   returns `nil`.
	///
	/// - SeeAlso: `index(of:)`
	public func index(
		where predicate: (Iterator.Element) throws -> Bool) rethrows -> Index? {
		var node = firstNode
		for i in 0 ..< count {
			if let item = node?.item, try predicate(item) {
				return i
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
	public func lastIndex(
		where predicate: (Iterator.Element) throws -> Bool) rethrows -> Index? {
		var node = lastNode
		for i in 0 ..< count {
			if let item = node?.item, try predicate(item) {
				return count - 1 - i
			}
			node = node?.previous
		}
		return nil
	}

	/// Returns a Boolean value indicating whether the list contains an element
	/// that satisfies the given predicate.
	///
	/// You can use the predicate to check for an element of a type that doesn't
	/// conform to the `Equatable` protocol, such as the `HTTPResponse`
	/// enumeration in this example.
	///
	///     enum HTTPResponse {
	///         case ok
	///         case error(Int)
	///     }
	///
	///     let lastThreeResponses: LinkedList<HTTPResponse> = [.ok, .ok, .error(404)]
	///     let hadError = lastThreeResponses.contains { element in
	///         if case .error = element {
	///             return true
	///         } else {
	///             return false
	///         }
	///     }
	///     // 'hadError' == true
	///
	/// Alternatively, a predicate can be satisfied by a range of `Equatable`
	/// elements or a general condition. This example shows how you can check a
	/// list for an expense greater than $100.
	///
	///     let expenses: LinkedList<Float> = [21.37, 55.21, 9.32, 10.18, 388.77]
	///     let hasBigPurchase = expenses.contains { $0 > 100 }
	///     // 'hasBigPurchase' == true
	///
	/// - Parameter predicate: A closure that takes an element of the list as its
	///   argument and returns a Boolean value that indicates whether the passed
	///   element represents a match.
	/// - Returns: `true` if the list contains an element that satisfies
	///    `predicate`; otherwise, `false`.
	public func contains(
		where predicate: (Iterator.Element) throws -> Bool) rethrows -> Bool {
		return try index(where: predicate) != nil
	}

	/// Returns the first element of the list that satisfies the given
	/// predicate or nil if no such element is found.
	///
	/// - Parameter predicate: A closure that takes an element of the
	///   list as its argument and returns a Boolean value indicating
	///   whether the element is a match.
	/// - Returns: The first match or `nil` if there was no match.
	public func first(
		where predicate: (Iterator.Element) throws -> Bool) rethrows -> Iterator.Element? {
		var node = firstNode
		for _ in 0 ..< count {
			if let item = node?.item, try predicate(item) {
				return item
			}
			node = node?.next
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
	public func last(
		where predicate: (Iterator.Element) throws -> Bool) rethrows -> Iterator.Element? {
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
	public func replaceSubrange<C>(_ subrange: Range<Index>,
	                               with newElements: C)
		where C: Swift.Collection, C.Iterator.Element == Iterator.Element {

		checkPositionIndex(subrange.lowerBound)
		checkPositionIndex(subrange.upperBound)

		var prev = node(at: subrange.lowerBound)?.previous

		var oldNext = prev?.next
	}

	internal func isPositionIndex(_ index: Index) -> Bool {
		return (0 ... count).contains(index)
	}

	internal func checkPositionIndex(_ index: Index) {
		if !isPositionIndex(index) {
			fatalError("Index out of bounds")
		}
	}

	internal func node(at index: Index) -> Node<Element>? {

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

	internal func unlink(_ node: Node<Element>) -> Element {
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

	public func index(
		of element: LinkedList.Iterator.Element) -> LinkedList.Index? {
		return index { $0 == element }
	}

	public func contains(_ element: LinkedList.Iterator.Element) -> Bool {
		return index(of: element) != nil
	}

	public func remove(_ element: LinkedList.Iterator.Element) -> Bool {
		return remove { $0 == element } != nil
	}

	public func lastIndex(
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
