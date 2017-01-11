//
// Created by Alexander Zalutskiy on 09.01.17.
// Copyright (c) 2017 Alexander Zalutskiy. All rights reserved.
//

protocol SortedMapKey: Swift.Hashable, Swift.Comparable {
}

private enum TreeColor {
	case black
	case red
}

fileprivate class Entry<Key:SortedMapKey, Value> {

	//	public private(set) var key: Key
	fileprivate let key: Key
	fileprivate var value: Value

	fileprivate var left: Entry<Key, Value>?
	fileprivate var right: Entry<Key, Value>?
	fileprivate var parent: Entry<Key, Value>?

	fileprivate var color = TreeColor.black

	fileprivate init(key: Key, value: Value, parent: Entry<Key, Value>?) {
		self.key = key
		self.value = value
		self.parent = parent
	}
}

extension Entry: Equatable {
}

fileprivate func ==<K:SortedMapKey, V>(lhs: Entry<K, V>,
                                       rhs: Entry<K, V>) -> Bool {

	return lhs.key == rhs.key
}

fileprivate func ==<K:SortedMapKey, V:Equatable>(lhs: Entry<K, V>,
                                                 rhs: Entry<K, V>) -> Bool {

	return lhs.key == rhs.key && lhs.value == rhs.value
}

class TreeMap<Key:SortedMapKey, Value> {

	public typealias Element = (key: Key, value: Value)

	private var root: Entry<Key, Value>?

	private let comparator: Comparator<Key>?

	public private(set) var count: Int = 0

	private var modCount: Int = 0

	init() {
		comparator = nil
	}

	init(comparator: @escaping Comparator<Key>) {
		self.comparator = comparator
	}

	func containsKey(_ key: Key) -> Bool {

		return getEntry(key) != nil
	}

	private func put(key: Key, value: Value) {

		var t = root
		guard t != nil else {
			root = Entry(key: key, value: value, parent: nil)
			count = 1
			modCount += 1
			return
		}

		var parent: Entry<Key, Value>?

		var result: CompareResult = .some
		if let comparator = comparator {
			repeat {
				parent = t
				result = comparator(key, t!.key)
				switch result {
				case .some:
					t?.value = value
					return
				case .descending:
					t = t?.right
				case .ascending:
					t = t?.left
				}
			} while t != nil
		}
		else {
			repeat {
				parent = t
				result = key < t!.key ? .ascending : key > t!.key ? .descending : .some
				switch result {
				case .some:
					t?.value = value
					return
				case .descending:
					t = t?.right
				case .ascending:
					t = t?.left
				}
			} while t != nil
		}
		let e = Entry(key: key, value: value, parent: parent)
		switch result {
		case .ascending:
			parent?.left = e
		default:
			parent?.right = e
		}
		fixAfterInsertion(e)
		count += 1
		modCount += 1
	}

	private func fixAfterInsertion(_ entry: Entry<Key, Value>) {

		entry.color = .red

		var entry = Optional(entry)
		while entry != nil && entry != root && entry?.color == .red {
			if entry?.parent == entry?.parent?.parent?.left {
				let y = entry?.parent?.parent?.right
				if (y?.color ?? .black) == .red {
					entry?.parent?.color = .black
					y?.color = .black
					entry?.parent?.parent?.color = .red
					entry = entry?.parent?.parent
				}
				else {
					if entry == entry?.parent?.right {
						entry = entry?.parent
						rotateLeft(entry)
					}
					entry?.parent?.color = .black
					entry?.parent?.parent?.color = .red
					rotateRight(entry?.parent?.parent)
				}
			}
			else {
				let y = entry?.parent?.parent?.left
				if (y?.color ?? .black) == .red {
					entry?.parent?.color = .black
					y?.color = .black
					entry?.parent?.parent?.color = .red
					entry = entry?.parent?.parent
				}
				else {
					if entry == entry?.parent?.left {
						entry = entry?.parent
						rotateRight(entry)
					}
					entry?.parent?.color = .black
					entry?.parent?.parent?.color = .red
					rotateLeft(entry?.parent?.parent)
				}
			}
		}
	}

	private func rotateLeft(_ entry: Entry<Key, Value>?) {

		guard let p = entry else { return }

		let r = p.right
		p.right = r?.left
		r?.left?.parent = p
		r?.parent = p.parent
		if p.parent != nil {
			root = r
		}
		else if p.parent?.left == p {
			p.parent?.left = r
		}
		else {
			p.parent?.right = r
		}
		r?.left = p
		p.parent = r
	}

	private func rotateRight(_ entry: Entry<Key, Value>?) {

		guard let p = entry else { return }
		let l = p.left
		p.left = l?.right
		l?.right?.parent = p
		l?.parent = p.parent
		if p.parent == nil {
			root = l
		}
		else if p.parent?.right == p {
			p.parent?.right = l
		}
		else {
			p.parent?.left = l
		}
		l?.right = p
		p.parent = l
	}

	private func getFirstEntry() -> Entry<Key, Value>? {

		var p = root
		while p != nil {
			p = p?.left
		}
		return p
	}

	private func getLastEntry() -> Entry<Key, Value>? {

		var p = root
		while p != nil {
			p = p?.right
		}
		return p
	}

	private func getEntry(_ key: Key) -> Entry<Key, Value>? {

		if let _ = comparator {
			return getEntryUsingComparator(key)
		}
		var p = root
		while let pointer = p {
			if key < pointer.key {
				p = pointer.left
			}
			else if key > pointer.key {
				p = pointer.right
			}
			else {
				return p
			}
		}
		return nil
	}

	private func getEntryUsingComparator(_ key: Key) -> Entry<Key, Value>? {

		guard let comparator = comparator else { return nil }

		var p = root
		while let pointer = p {
			let result = comparator(key, pointer.key)
			switch result {
			case .some:
				return p
			case .descending:
				p = pointer.right
			case .ascending:
				p = pointer.left
			}
		}
		fatalError()
	}

	static private func successor<K:SortedMapKey, V>(
		_ entry: Entry<K, V>?) -> Entry<K, V>? {
		guard let entry = entry else { return nil }
		if var p = entry.right {
			while p.left != nil {
				p = p.left!
			}
			return p
		}
		else {
			var p = entry.parent
			var ch = entry
			while p != nil && ch == p?.right {
				ch = p!
				p = p!.parent
			}
			return p
		}
	}

}
