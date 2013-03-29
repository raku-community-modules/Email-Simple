use v6;
use Test;

use lib 'lib';

use Email::Simple;

plan 12;

my %headers = (
    badly-folded    => {
        X-Original-To   => 'adam@mail1.internal.foo.com',
        From            => 'x <x@foo.com>',
        User-Agent      => 'Mozilla Thunderbird 1.0.6 (Windows/20050716)',
        Subject         => 'My subject',
    },
    josey-nobody    => {
        Received        => '(qmail 1679 invoked by uid 503); 13 Nov 2002 10:10:49 -0000',
        To              => 'austin-group-l@opengroup.org',
        Content-Type    => 'text/plain; charset=us-ascii',
    },
    junk-in-header  => {
        Header-One      => 'steve biko',
        Header-Two      => 'stir it up',
    },

);

for %headers.keys.sort -> $file {
    my $m;
   lives_ok {$m = Email::Simple.new(slurp "t/test-mails/$file") }, "Could parse $file";;
   my %h := %headers{$file};
   for %h.sort -> $p {
       is $m.header($p.key), $p.value, "Header $p.key() in mail $file";
   }
}
