module dsl

import os
import treevee

// my owm dsl Config.tree
pub type Config = treevee.Tree

pub fn Config.from_file(path string) !Config{
	mut str := os.read_file(path) or { panic(err) }
	tree := treevee.Tree.from_string_with_uri(str.trim_space() + '\n', '?') or { panic(err) }
	return Config(*tree)
}


// helper methods

pub fn (config Config) to_file(path string) !{
	os.write_file(path, config.to_string()) or { panic(err) }
}

pub type InsertData = string | Config

pub fn (tree &Config) add_item_to_array(value InsertData, path ...treevee.TreePath) &Config {
	insert_node := match value {
		string { Config{value: value} }
		Config { value }
	}

	last := path.last()
	match last {
		string {
			mut data := tree.value(...path).kids.clone()
			data << &insert_node
			inseerted := tree.insert(tree.struct(last, data), ...path)
			return inseerted
		}

		int {
			println(path)
			panic("TODO: need implement support int path")
		}
	}
}

pub fn (tree &Config) replace_value(value InsertData, path ...treevee.TreePath) &Config {
	insert_node := match value {
		string { Config{value: value} }
		Config { value }
	}

	mut unpack_first := path.clone()
	unpack_first << ''

	return tree.insert(insert_node, ...unpack_first)
}
