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

open class LinkedListIterator<Element>: IteratorProtocol {

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

open class LinkedList<Element>: Swift.Collection {

	public typealias Index = Int

	public typealias Iterator = LinkedListIterator<Element>

	public private(set) var count: Int = 0

	var firstNode: Node<Element>?

	var lastNode: Node<Element>?

	var modCount: Int = 0

	public init() {

	}

	public convenience init<Source:Sequence>(collection: Source)
		where Source.Iterator.Element == Element {
		self.init()
		_ = append(contentsOf: collection)
	}

	public func append<Source:Sequence>(contentsOf: Source)
		where Source.Iterator.Element == Element {
		append(contentsOf: contentsOf, at: count)
	}

	public func append<Source:Sequence>(contentsOf: Source, at index: Index)
		where Source.Iterator.Element == Element {
		checkPositionIndex(index)

		let succ: Node<Element>?
		var pred: Node<Element>?

		if index == count {
			succ = nil
			pred = lastNode
		}
		else {
			succ = node(at: index)
			pred = succ?.previous
		}

		var fromSize = 0

		for obj in contentsOf {
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

	public func append(_ newElement: Element) {
		linkLast(newElement)
	}

	public var first: Element? {
		return firstNode?.item
	}

	public var last: Element? {
		return lastNode?.item
	}

	public var startIndex: Index {
		return 0
	}

	public var endIndex: Index {
		return count - 1
	}

	public func formIndex(after i: inout Index) {
		i += 1
	}

	public func index(after i: Index) -> Index {
		return i + 1
	}

	public func makeIterator() -> Iterator {
		return LinkedListIterator(node: firstNode)
	}

	public subscript(position: Index) -> Element {
		checkPositionIndex(position)
		return node(at: position)!.item
	}

	func isPositionIndex(_ index: Index) -> Bool {
		return (0 ... count).contains(index)
	}

	func checkPositionIndex(_ index: Index) {
		if !isPositionIndex(index) {
			fatalError("Index out of bounds")
		}
	}

	func node(at index: Index) -> Node<Element>? {

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

	func linkLast(_ newElement: Element) {
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

}

public extension LinkedList where Element: Swift.Equatable {

	func index(of element: LinkedList.Iterator.Element) -> LinkedList.Index? {
		var node = firstNode
		for i in 0 ..< count {
			if let item = node?.item, item == element {
				return i
			}
			node = node?.next
		}
		return nil
	}

}
