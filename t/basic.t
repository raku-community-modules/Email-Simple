use v6;
use Test;

BEGIN { @*INC.push: './lib'; }

use Email::Simple;

my $mail-text = slurp './t/test-mails/josey-nofold';

my $mail = Email::Simple.new($mail-text);

plan 1;

my $old-from;
is $old-from = $mail.header('From'), 'Andrew Josey <ajosey@rdg.opengroup.org>', "We can get a header";
