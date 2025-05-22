module treevee

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

// string - return string reptresentation of text node value. (same as `.text()` or `.str()`)
pub fn (tree &Tree) string() string {
	return tree.text()
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

pub fn (tree &Tree) add_item_to_array2(value &Tree, path ...TreePath) &Tree {
	mut current_elemets_node := tree.select(path)
	current_elemets_node.kids[0].kids << value
	return tree.insert(current_elemets_node, path)
	// return tree.insert(value, path)
}

pub type InsertData = string | Tree


// pub fn (tree &Tree) add_item_to_array(value InsertData, path ...TreePath) &Tree {
// 	insert_node := match value {
// 		string { Tree{value: value} }
// 		Tree { value }
// 	}

// 	last := path.last()
// 	match last {
// 		string {
// 			mut data := tree.value(...path).kids.clone()
// 			data << &insert_node
// 			inseerted := tree.insert(tree.struct(last, data), ...path)
// 			return inseerted
// 		}

// 		int {
// 			println(path)
// 			panic("TODO: need implement support int path")
// 		}
// 	}
// }

// pub fn (tree &Tree) replace_value(value InsertData, path ...TreePath) &Tree {
// 	insert_node := match value {
// 		string { Tree{value: value} }
// 		Tree { value }
// 	}

// 	mut unpack_first := path.clone()
// 	unpack_first << ''

// 	return tree.insert(insert_node, ...unpack_first)
// }
