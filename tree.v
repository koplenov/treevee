module treevee

pub struct Tree {
pub:
	//	Type of structural node, `value` should be empty
	type string

	// Content of data node, `type` should be empty
	value string
pub mut:
	//	Child nodes
	kids []&Tree

	span Span
}

pub fn Tree.list(kids []&Tree, span Span) &Tree {
	return &Tree{
		type:  ''
		value: ''
		kids:  kids
		span:  span
	}
}

// Parses tree format from string.
pub fn Tree.from_string(str string) !&Tree {
	return Tree.from_string_with_uri(str, '?')
}

pub fn Tree.from_string_with_uri(str string, uri string) !&Tree {
	span := Span.entire(uri, str)
	root := Tree.list([], span)

	mut stack := [root]

	mut pos := 0
	mut row := 0
	mut min_indent := 0

	for str.len > pos {
		mut indent := 0
		mut line_start := pos

		row++

		for str.len > pos && str[pos] == `\t` {
			indent++
			pos++
		}

		if root.kids.len == 0 {
			min_indent = indent
		}

		indent -= min_indent

		if indent < 0 || indent >= stack.len {
			sp := span.span(row, 1, pos - line_start)

			for str.len > pos && str[pos] != `\n` {
				pos++
			}

			if indent < 0 {
				if str.len > pos {
					return error('Too few tabs ${str[line_start..pos]} ${sp}')
				}
			} else {
				return error('Too many tabs ${str[line_start..pos]} ${sp}')
			}
		}

		stack = stack[..indent + 1].clone()
		mut parent := stack[indent]

		for str.len > pos && str[pos] != `\\` && str[pos] != `\n` {
			error_start := pos

			for str.len > pos && (str[pos] == ` ` || str[pos] == `\t`) {
				pos++
			}

			if pos > error_start {
				mut line_end := str[pos..].index_u8(`\n`)

				if line_end == -1 {
					line_end = str.len
				}

				sp := span.span(row, error_start - line_start + 1, pos - error_start)

				return error('Wrong nodes separator ${str[line_start..line_end]} ${sp}')
			}

			type_start := pos

			for str.len > pos && str[pos] != `\\` && str[pos] != ` ` && str[pos] != `\t`
				&& str[pos] != `\n` {
				pos++
			}

			if pos > type_start {
				mut next := &Tree{
					type:  str[type_start..pos]
					value: ''
					kids:  []
					span:  span.span(row, type_start - line_start + 1, pos - type_start)
				}

				parent.kids << next
				parent = next
			}

			if str.len > pos && str[pos] == ` ` {
				pos++
			}
		}

		if str.len > pos && str[pos] == `\\` {
			data_start := pos

			for str.len > pos && str[pos] != `\n` {
				pos++
			}

			mut next := &Tree{
				type:  ''
				value: str[data_start + 1..pos]
				kids:  []
				span:  span.span(row, data_start - line_start + 2, pos - data_start - 1)
			}

			parent.kids << next
			parent = next
		}

		if str.len == pos && stack.len > 0 {
			sp := span.span(row, pos - line_start + 1, 1)
			return error('Unexpected EOF, LF required ${str[line_start..str.len]} ${sp}')
		}

		stack << parent
		pos++
	}

	return root
}

// Makes struct node.
pub fn Tree.struct(type string, kids []&Tree, span Span) &Tree {
	return &Tree{
		type:  type
		value: ''
		kids:  kids
		span:  span
	}
}

// Makes new derived structural node.
pub fn (tree Tree) struct(type string, kids []&Tree) &Tree {
	return &Tree{
		type:  type
		value: ''
		kids:  kids
		span:  tree.span
	}
}

// Returns multiline text content.
pub fn (tree &Tree) text() string {
	mut values := []string{}
	for kid in tree.kids {
		if kid.type != '' {
			continue
		}
		values << kid.value
	}
	return tree.value + values.join('\n')
}

// Serializes to tree format.
pub fn (tree &Tree) to_string() string {
	mut output := []string{}
	tree_dump(tree, '', mut output)
	return output.join('')
}

// str returns serialized tree node
pub fn (tree &Tree) str() string {
	return tree.to_string()
}

fn tree_dump(input_tree &Tree, preffix string, mut output []string) {
	mut input_preffix := preffix

	if input_tree.type != '' {
		if input_preffix == '' {
			input_preffix = '\t'
		}

		output << input_tree.type

		if input_tree.kids.len == 1 {
			output << ' '
			tree_dump(input_tree.kids[0], input_preffix, mut output)
			return
		}

		output << '\n'
	} else if input_tree.value != '' || input_preffix.len > 0 {
		output << '\\' + input_tree.value + '\n'
	}

	for kid in input_tree.kids {
		output << input_preffix
		tree_dump(kid, preffix + '\t', mut output)
	}
}

pub type TreePath = string | int

// select - Query nodes by path.
pub fn (tree &Tree) select(path ...TreePath) &Tree {
	mut next := [tree]

	for type in path {
		prev := next
		next = []&Tree{}

		for item in prev {
			match type {
				string {
					for child in item.kids {
						if child.type == type {
							next << child
						}
					}
				}
				int {
					for child in item.kids {
						if type < item.kids.len {
							next << child.kids[type]
						}
					}
				}
			}
		}
	}

	return Tree.list(next, tree.span)
}

// insert - Returns a new tree with `value` inserted or replaced at the given path.
// - If path is empty, replaces the current node with `value`.
// - For string path: replaces or inserts a struct node with the given type.
// - For int path: replaces or inserts at the given index, extending with empty nodes if needed.
pub fn (tree &Tree) insert(value &Tree, path ...TreePath) &Tree {
	if path.len == 0 {
		if value == unsafe { nil } { return Tree.list([], tree.span) }
		return &Tree{
			type: value.type
			value: value.value
			kids: value.kids.clone()
			span: value.span
		}
	}

	match path[0] {
		string {
			typ := path[0] as string
			mut found := false
			mut kids := []&Tree{}
			for item in tree.kids {
				if item.type == typ {
					found = true
					kids << item.insert(value, ...path[1..])
				} else {
					kids << item
				}
			}
			if !found && value != unsafe { nil } {
				kids << tree.struct(typ, []&Tree{}).insert(value, ...path[1..])
			}
			return tree.struct(tree.type, kids)
		}

		int {
			idx := path[0] as int
			mut kids := tree.kids.clone()
			for kids.len <= idx {
				kids << &Tree{
					type: ''
					value: ''
					kids: []&Tree{}
					span: tree.span
				}
			}
			kids[idx] = kids[idx].insert(value, ...path[1..])
			return tree.struct(tree.type, kids)
		}
	}

	// fallback: unreachable, for safety
	mut kids := if tree.kids.len == 0 { [Tree.list([], tree.span)] } else { tree.kids.clone() }
	for i, kid in kids {
		kids[i] = kid.insert(value, ...path[1..])
	}
	return tree.struct(tree.type, kids)
}
