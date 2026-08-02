use Email::Simple::Header;

unit class Email::Simple;
has $.header;
has $.body = "";
has $.crlf = "\r\n";

#- RFC2822 handling ------------------------------------------------------------
# Basically swiped / simplified from DateTime::strftime

my constant @weekdays = <Sun Mon Tue Wed Thu Fri Sat Sun>;
my constant @months = <? Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>;

my sub percent02i($value) { $value < 10 ?? "0$value" !! $value.Str }

my sub timezone(Int() $timezone) {
    my str $tz =
      $timezone.abs.polymod(60,60).skip.reverse.map(&percent02i).join;
    $timezone < 0 ?? "-$tz" !! "+$tz"
}

my sub rfc2822() {
    my $dt := DateTime.now;
    sprintf("%s, %02d %s %d %s %s",
      @weekdays[$dt.day-of-week],
      $dt.day,
      @months[$dt.month],
      $dt.year,
      $dt.hh-mm-ss,
      timezone($dt.timezone)
    )
}

#- parsing ---------------------------------------------------------------------
my regex headers { .*? }
my token separator {
    [\x0a\x0d\x0a\x0d] | [\x0d\x0a\x0d\x0a] | \x0a ** 2 | \x0d ** 2
}
my token body { .*  }

multi method new(Str:D $text, :$class = Email::Simple::Header) {

    # Looks like a proper email
    if $text.match(/ <headers> <separator> <body> /) {
        my $newlines := ~$<separator>;
        my $crlf     := $newlines.NFC[^($newlines.codes / 2)]>>.chr.join;
        my $headers  := $<headers> ~ $crlf;
        my $header   := $class.new($headers, :$crlf);
        self.bless: :body(~$<body>), :$header, :$crlf
    }

    # no header separator found, so it must be a header-only email
    else {
        my $crlf = ~($text ~~ / \xa\xd | \xd\xa | \xa | \xd /);
        self.bless: :header($class.new($text, :$crlf)), :$crlf
    }
}

#- bespoke creation -----------------------------------------------------------
multi method new(Array() $header, Str $body, :$header-class = Email::Simple::Header) {
    self.create :$header, :$body, :$header-class
}

method create(
  Array() :$header is copy,
  Str     :$body,
  Mu      :$header-class = Email::Simple::Header
) {
    $header := $header-class.new($header, crlf => "\r\n");

    $header.header-set('Date',rfc2822) unless $header.header('Date');

    self.bless: :$body, :$header
}

#- methods ---------------------------------------------------------------------
method header-obj { $!header }
method header-obj-set ($obj) { $!header = $obj }

method header($name, :$multi) { $!header.header($name, :$multi); }
method header-set($name, *@lines) { $!header.header-set($name, |@lines); }
method header-names() { $!header.header-names; }
method headers()  { self.header-names; }
method header-pairs()  { $!header.header-pairs; }

method body-set($text) { $!body = $text; }
method as-string() { $!header.as-string ~ $!crlf ~ $!body }
method Str() { self.as-string }

# vim: expandtab shiftwidth=4
