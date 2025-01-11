![](https://github.com/koplenov/treevee/blob/master/docs/banner.png?raw=true)
<div align="center">
    <h1>treevee</h1>
    <p>is a V implementation of a parser for the tree format</p>
</div>

This is the WIP (work in progress) to provide [v](https://vlang.io) support for the [tree format](https://github.com/hyoo-ru/mam_mol/tree/master/tree2) of the [$mol frontend framework](https://github.com/hyoo-ru). Use it like this:

```v
import koplenov.treevee

fn main() {
    treeveee.Tree.from_string("simple_config") or { panic(err) }
}
```


## Installing
- Using vpm: `v install koplenov.treevee`


## Usage

### Select values:

```v
tree := treeve.Tree.from_string_file("./tests/example_1.tree") or { panic(err) }

// integer
assert tree.value("port").int() == 8079

// string
assert tree.value("port").text() == "8079"
assert tree.value("database_root_password").text() == ""
assert tree.value("default_htaccess").text() == ".htaccess"
assert tree.value("server_name").text() == "default server name"
```

### Select nested values:

```v
tree := treeve.Tree.from_string_file("./tests/example_2.tree") or { panic(err) }

assert tree.select("server", "auth").kids[0].kids.len == 2
assert tree.value("server", "auth", "login").text() == "root"
assert tree.value("server", "auth", "password").text() == "qwerty"
```

### Select arrays:

```v
tree := treeve.Tree.from_string_file("./tests/example_3.tree") or { panic(err) }
// of strings
assert tree.value("user","hobby").array() == ['kendo', 'dance', 'role play']

// of numbers
assert tree.value("user","loved_numbers").array_int() == [7, 21, 42]
```
