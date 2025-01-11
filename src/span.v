module treeve

pub struct Span {
pub:
	uri    string
	source string
	row    int
	col    int
	length int
}

// Span.begin - Span for begin of unknown resource.
pub fn Span.begin(uri string, source string) Span {
	return Span{uri, source, 1, 1, 0}
}

// Span.end - Makes new span for end of resource.
pub fn Span.end(uri string, source string) Span {
	return Span{uri, source, 1, source.len + 1, 0}
}

// Span.entire - Makes new span for entire resource.
pub fn Span.entire(uri string, source string) Span {
	return Span{uri, source, 1, 1, source.len}
}

pub fn (span Span) span(row int, col int, length int) Span {
	return Span{
		uri:    span.uri
		source: span.source
		row:    row
		col:    col
		length: length
	}
}

// Span.unknown - Span for begin of unknown resource.
pub fn Span.unknown() Span {
	return Span.begin('?', '')
}

pub fn (span Span) to_string() string {
	return span.str()
}

pub fn (span Span) str() string {
	return '${span.uri}#${span.row}:${span.col}/${span.length}'
}
