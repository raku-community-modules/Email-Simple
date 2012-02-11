class Email::Simple::Header;

grammar Headers {
    token TOP {
	<name>: \s* <value> <newline>
    }
    token name {
	[^: ]*
    }
    token value {
	[^<newline>]*
	( <newline> \s+ [^:] [^<newline>]* ) *
    }
    token newline {
	"\n" | "\r" | "\r\n" | "\n\r"
    }
}

