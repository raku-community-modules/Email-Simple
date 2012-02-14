class Email::Simple;

use Email::Simple::Header;

has $!body;
has $!header;
has $!crlf;

grammar Message {
  regex TOP {
    <headers>
    <newline>
    <body>
  }
  token newline {
    \n | \r | \r\n | \n\r
  }
  token body {
    .*
  }
  regex headers {
    .*? <newline>
  }
}

multi method new (Str $text) {
    my $parsed = Message.parse($text);
    my $header-object = Email::Simple::Header.new(~$parsed<headers>, crlf => ~$parsed<newline>);
    self.bless(*, body => $parsed<body>, header => $header-object, crlf => ~$parsed<newline>);
}

multi method new (Array $header, Str $body) {
    self.create(header => $header, body => $body);
}

method create (Array :$header, Str :$body) {
    my $header-object = Email::Simple::Header.new($header, crlf => "\r\n");
    self.bless(*, body => $body, header => $header-object, crlf => "\r\n");
}

submethod BUILD (:$!body, :$!header, :$!crlf) { }

method header-obj {
    return $!header;
}

method header-obj-set ($obj) {
    $!header = $obj;
}

method header ($name) { $!header.header($name); }
method header-set ($name, *@lines) { $!header.header-set($name, |@lines); }
method header-names { $!header.header-names; }
method headers { self.header-names; }
method header-pairs { $!header.header-pairs; }

method body {
    return $!body;
}

method body-set ($text) {
    $!body = $text;
}

method as-string {
    return $!header.as-string ~ $!crlf ~ $!body;
}
method Str { self.as-string; }

method crlf {
    return $!crlf;
}
