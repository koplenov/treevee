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

fn test_tree_insert() {
	// a b c d\n insert x at a b c => a b x\n
	tree := treevee.Tree.from_string('a b c d\n') or { panic(err) }
	inserted := tree.insert(tree.struct('x', []&treevee.Tree{}), 'a', 'b', 'c')
	assert inserted.to_string() == 'a b x\n'

	// a b\n insert x at a b c d => a b c x\n
	tree2 := treevee.Tree.from_string('a b\n') or { panic(err) }
	inserted2 := tree2.insert(tree2.struct('x', []&treevee.Tree{}), 'a', 'b', 'c', 'd')
	assert inserted2.to_string() == 'a b c x\n'

	// a b c d\n insert x at 0 0 0 => a b x\n
	tree3 := treevee.Tree.from_string('a b c d\n') or { panic(err) }
	inserted3 := tree3.insert(tree3.struct('x', []&treevee.Tree{}), 0, 0, 0)
	assert inserted3.to_string() == 'a b x\n'

	// a b c d\n insert x at none none none => a b x\n
	tree4 := treevee.Tree.from_string('a b c d\n') or { panic(err) }
	inserted4 := tree4.insert(tree4.struct('x', []&treevee.Tree{}))
	assert inserted4.to_string() == 'x\n'

	// a b\n insert x at 0 0 0 0 => a b \\\n\tx\n
	tree5 := treevee.Tree.from_string('a b\n') or { panic(err) }
	inserted5 := tree5.insert(tree5.struct('x', []&treevee.Tree{}), 0, 0, 0, 0)
	assert inserted5.to_string() == 'a b \\\n\tx\n'

	// a b\n insert x at none none none none => a b \\\n\tx\n
	tree6 := treevee.Tree.from_string('a b\n') or { panic(err) }
	inserted6 := tree6.insert(tree6.struct('x', []&treevee.Tree{}))
	assert inserted6.to_string() == 'x\n'
}
