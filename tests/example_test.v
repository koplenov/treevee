module main

import treevee
import os

fn test_tree_to_string_raw() {
	tree_string := r'user
	name \Jin
	age 35
	hobby
		\kendo
		\dance
		\role play
'
	tree := treevee.Tree.from_string(tree_string) or { panic(err) }
	assert tree.to_string() == tree_string
}


fn test_tree_to_string_from_file() {
	tree_string := os.read_file("./tests/example_1.tree") or { panic(err) }
	tree := treevee.Tree.from_string(tree_string) or { panic(err) }
	assert tree.to_string() == tree_string
}


fn test_tree_to_string_from_file_2() {
	tree_string := os.read_file("./tests/example_2.tree") or { panic(err) }
	tree := treevee.Tree.from_string_file("./tests/example_2.tree") or { panic(err) }
	assert tree.to_string() == tree_string
}

fn test_select_value() {
	tree := treevee.Tree.from_string_file("./tests/example_1.tree") or { panic(err) }
	assert tree.value("port").int() == 8079
	assert tree.value("port").text() == "8079"
	assert tree.value("database_root_password").text() == ""
	assert tree.value("default_htaccess").text() == ".htaccess"
	assert tree.value("server_name").text() == "default server name"
}

fn test_select_nested_value() {
	tree := treevee.Tree.from_string_file("./tests/example_2.tree") or { panic(err) }
	assert tree.select("server", "auth").kids[0].kids.len == 2
	assert tree.value("server", "auth", "login").text() == "root"
	assert tree.value("server", "auth", "password").text() == "qwerty"
}

fn test_select_array() {
	tree := treevee.Tree.from_string_file("./tests/example_3.tree") or { panic(err) }
	assert tree.value("user","hobby").array_of_strings() == ['kendo', 'dance', 'role play']
	assert tree.value("user","loved_numbers").array_of_ints() == [7, 21, 42]
}
