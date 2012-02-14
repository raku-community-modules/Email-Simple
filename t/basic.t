use v6;
use Test;

BEGIN { @*INC.push: './lib'; }

use Email::Simple;

my $mail-text = slurp './t/test-mails/josey-nofold';

my $mail = Email::Simple.new($mail-text);

plan 3;

my $old-from;
is $old-from = $mail.header('From'), 'Andrew Josey <ajosey@rdg.opengroup.org>', "We can get a header";
my $sc = 'Simon Cozens <simon@cpan.org>';
is $mail.header-set("From", $sc), $sc, "Setting returns new value";
is $mail.header("From"), $sc, "Which is consistently returned";
