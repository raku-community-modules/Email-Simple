class Email::Simple::Header;

has $!crlf;
has @!headers;

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

method new ($header-text, :$crlf = "\r\n") {

    my $parsed = Headers.parse($header-text);
    my @headers;
    for 1..+@parsed<name> {
	my $name = @parsed<name>[$_];
	my $value = @parsed<value>[$_];
	$value ~~ s/\s*$crlf\s*/ /g;
	push(@headers, [$name, $value]);
    }

    self.bless(*, crlf => $crlf, headers => @headers);
}

submethod BUILD (:$!crlf, :@!headers) { }

method as-string {
    my $header-str;
    
    for @!headers {
	my $header = $_[0] ~ ': ' ~ $_[1];
	$header-str ~= self!fold($header);
    }

    return $header-str;
}
method Str { self.as-string }

method header-names {
    
}

method header-pairs {

}

method header ($name) {

}

method header-set (:$field) {

}

method crlf {
    return $!crlf;
}

method !fold ($line) {
    my $limit = self!default-fold-at - 1;
    
    if $line.chars <= $limit {
	return $line ~ self.crlf;
    }

    my $folded;
    while $line.chars {
	if $line ~~ s/^(.{0,$limit})\s// {
	    $folded ~= $1 ~ self.crlf;
	    if $line.chars {
		$folded ~= self!default-fold-indent;
	    }
	} else {
	    $folded ~= $line ~ self.crlf;
	    $line = '';
	}
    }

    return $folded;
}
method !default-fold-at { 78 }
method !default-fold-indent { " " }
