//
// Created by Alexander Zalutskiy on 09.01.17.
// Copyright (c) 2017 Alexander Zalutskiy. All rights reserved.
//

public enum CompareResult {
	case some
	case descending
	case ascending
}

public typealias Comparator<K> = (K, K) -> CompareResult