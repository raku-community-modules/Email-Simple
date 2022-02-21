unit class Email::Simple::Header;

has $!crlf;
has @!headers;

multi method new(Array $headers, Str :$crlf = "\x0d\x0a") {
    if $headers[0] ~~ Array {
        self.bless: :$crlf, :$headers
    }
    elsif $headers[0] ~~ Pair {
        self.bless: :$crlf, headers => $headers.map(*.kv)
    }
    else {
        my @folded-headers;
        for @$headers -> $key, $value? {
            @folded-headers.push: ($key, $value)
        }

        self.bless: :$crlf, headers => @folded-headers
    }
}

multi method new(Str $header-text, Str :$crlf = "\x0d\x0a") {
    #define this grammar here
    #because we need $crlf
    # (and I don't know if it's possible to pass parameters
    #  through Headers.parse())
    grammar Headers {
        regex TOP {
            <entry>+
        }
        regex entry {
            <name>\: \s* <value> <newline>
            || <junk> <newline>
        }
        token name {
            <-[:\s]>+
        }
        regex value {
            \N+
            [<newline> \h+ \N+?]*
        }
        token newline {
            $crlf
        }
        token junk {
            \N+
        }
    }

    my $parsed = Headers.parse($header-text);
    my @entries = $parsed<entry>.list;
    my @headers;
    for @entries {
        # TODO: store ~.<junk> somehow?
        next if .<junk>;
        my $name = $_<name>;
        my $value = $_<value>;
        $value = $value.Str;
        $value ~~ s:g/\s* $crlf \s*/ /;
        push(@headers, [~$name, $value]);
    }

    self.bless: :$crlf, :@headers
}

submethod BUILD(:$!crlf, :@!headers) { }

method as-string() {
    my $header-str;

    for @!headers {
        my $header = $_[0] ~ ': ' ~ $_[1];
        $header-str ~= self!fold($header);
    }

    $header-str
}
method Str() { self.as-string }

method header-names() { @!headers.map: *.[0] }

method header-pairs() { @!headers }

method header(Str $name, :$multi) {
    my @values = gather {
        for @!headers {
            if lc($_[0]) eq lc($name) {
            take $_[1];
            }
        }
    }

    +@values
      ?? $multi
        ?? @values
        !! @values[0]
      !! Nil
}

method header-set($field, *@values) {
    my @indices;
    my $x = 0;
    for @!headers {
        if lc($_[0]) eq lc($field) {
            push(@indices, $x);
        }
        $x++;
    }

    if +@indices > +@values {
        my $overage = +@indices - +@values;
        for 1..$overage {
            @!headers.splice(@indices[*-1],1);
            @indices.pop();
        }
    }
    elsif +@values > +@indices {
        my $underage = +@values - +@indices;
        for 1..$underage {
            @!headers.push([$field, '']);
            @indices.push(+@!headers-1);
        }
    }

    for 0..(+@indices - 1) {
        @!headers[@indices[$_]] = [$field, @values[$_]];
    }

    +@values
      ?? @values
      !! Nil
}

method crlf() { $!crlf }

method !fold(Str:D $line is copy) {
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
        }
        else {
            $folded ~= $line ~ self.crlf;
            $line = '';
        }
    }

    $folded
}
method !default-fold-at() { 78 }
method !default-fold-indent() { " " }

# vim: expandtab shiftwidth=4
