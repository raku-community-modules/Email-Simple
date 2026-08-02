unit class Email::Simple::Header;

has $.crlf;
has @.headers;
has %!headers;

multi method new(Array $headers, Str :$crlf = "\x0d\x0a") {
    if $headers[0] ~~ Array {
        self.bless: :$crlf, :$headers
    }
    elsif $headers[0] ~~ Pair {  # UNCOVERABLE
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
    my grammar Headers {
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
        @headers.push([
          .<name>.Str,
          .<value>.subst(/ \s* $crlf \s* /, ' ', :global)
        ]) unless .<junk>;
    }

    self.bless: :$crlf, :@headers
}

submethod TWEAK(--> Nil) {
    # create easier lookup of headers
    my %headers is default(Nil);
    %headers.push(.[0].lc => .[1]) for @!headers;
    %!headers := %headers;
}

method as-string() {
    @!headers.map({
        self!fold("$_[0]: $_[1]")
    }).join
}
method Str() { self.as-string }

method header-names() { @!headers.map: *.[0] }

method header-pairs() { @!headers }

method header(Str $name, :$multi) {
    $multi
      ?? %!headers{$name.lc}.List
      !! %!headers{$name.lc}.head
}

method header-set($field, *@values) {
    return Nil unless @values;

    my $field-lc := $field.lc;

    my @indices;
    my $x = 0;
    for @!headers {
        if $_[0].lc eq $field-lc {
            push(@indices, $x);
        }
        $x++;
    }

    if @indices > @values {
        my $overage = @indices - @values;
        for 1..$overage {
            @!headers.splice(@indices[*-1],1);
            @indices.pop();
        }
    }
    elsif @values > @indices {
        my $underage = @values - @indices;
        for 1..$underage {
            @!headers.push([$field, '']);
            @indices.push(@!headers - 1);
        }
    }

    for ^@indices {
        @!headers[@indices[$_]] = [$field, @values[$_]];
    }

    # do the same but in the hash
    if %!headers{$field-lc} -> $current {
        $current ~~ Array
          ?? $current.prepend(@values)
          !! (%!headers{$field-lc} := [|@values,$current]);
    }
    else {
        %!headers.append($field-lc, @values);
    }

    @values
}

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
