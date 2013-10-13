class Email::Simple;

use Email::Simple::Header;
use DateTime::Format::RFC2822;

has $!body;
has $!header;
has $!crlf;

grammar Message {
  regex TOP {
    <headers>
    <header-separate>
    <body>
  }
  token header-separate {
      [\x0a\x0d] ** 2 | [\x0d\x0a] ** 2 | \x0a ** 2 | \x0d ** 2
  }
  token body {
    .*
  }
  regex headers {
    .*?
  }
}

multi method new (Str $text) {
    my $parsed = Message.parse($text);
    unless $parsed {
        # no header separator found, so it must be a header-only email
        my $crlf = ~($text ~~ /\xa\xd|\xd\xa|\xa\xd/) || "\n",;
        return self.bless(
                body   => '',
                header => Email::Simple::Header.new($text, :$crlf),
                :$crlf,
        );
    }
    my $newlines = ~$parsed<header-separate>;
    my $crlf = $newlines.substr(0, ($newlines.chars / 2));
    my $headers = ~$parsed<headers>;
    $headers ~= $crlf;
    my $header-object = Email::Simple::Header.new($headers, crlf => $crlf);
    self.bless(body => $parsed<body>, header => $header-object, crlf => $crlf);
}

multi method new (Array $header, Str $body) {
    self.create(header => $header, body => $body);
}

method create (Array :$header, Str :$body) {
    my $header-object = Email::Simple::Header.new($header, crlf => "\r\n");
    if !($header-object.header('Date')) {
        $header-object.header-set('Date', DateTime::Format::RFC2822.to-string(DateTime.new(now)));
    }
    self.bless(body => $body, header => $header-object, crlf => "\r\n");
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
