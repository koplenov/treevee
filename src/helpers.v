module treeve

import os

// value - Select and unpack first value Tree node by path.
// Example `node.value("port").int()` or `node.value("config", "port").int()`
// If u need select node without take value, user `select`
pub fn (tree &Tree) value(path ...TreePath) &Tree {
	mut unpack_first := path.clone()
	unpack_first << ''
	return tree.select(unpack_first)
}

pub fn Tree.from_string_file(path string) !&Tree {
	mut str := os.read_file(path) or { panic(err) }
	return Tree.from_string_with_uri(str.trim_space() + '\n', '?')
}

// int - return int reptresentation of text node value.
pub fn (tree &Tree) int() int {
	return tree.text().int()
}

// array - return string array reptresentation of text node value.
pub fn (tree &Tree) array() []string {
	return tree.text().split_into_lines()
}

// array - return int array reptresentation of text node value.
pub fn (tree &Tree) array_int() []int {
	return tree.text().split_into_lines().map(it.int())
}
