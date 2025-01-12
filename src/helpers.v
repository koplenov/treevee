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

// bool - return bool reptresentation of text node value.
pub fn (tree &Tree) bool() bool {
	return tree.text().bool()
}

// array_of_strings - return strings array reptresentation of text node value.
pub fn (tree &Tree) array_of_strings() []string {
	return tree.text().split_into_lines()
}

// array_of_ints - return int array reptresentation of text node value.
pub fn (tree &Tree) array_of_ints() []int {
	return tree.array_of_strings().map(it.int())
}

// array_of_bool - return bool array reptresentation of text node value.
pub fn (tree &Tree) array_of_bool() []bool {
	return tree.array_of_strings().map(it.bool())
}
