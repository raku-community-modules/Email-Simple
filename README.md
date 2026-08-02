[![Actions Status](https://github.com/raku-community-modules/Email-Simple/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/Email-Simple/actions) [![Actions Status](https://github.com/raku-community-modules/Email-Simple/actions/workflows/macos.yml/badge.svg)](https://github.com/raku-community-modules/Email-Simple/actions) [![Actions Status](https://github.com/raku-community-modules/Email-Simple/actions/workflows/windows.yml/badge.svg)](https://github.com/raku-community-modules/Email-Simple/actions)

NAME
====

Email::Simple - Simple email parsing module

SYNOPSIS
========

```raku
use Email::Simple;

my $eml = Email::Simple.new($raw-mail-text);
say $eml.body;

my $new = Email::Simple.create(
  header => [
    ['To', 'mail@example.com'],
    ['From', 'me@example.com'],
    ['Subject', 'test']
  ],
  body => 'This is a test.',
);
say ~$new;
```

DESCRIPTION
===========

This distribution provides a simple way of composing the raw contents of an email, given a set of headers and a body. Or given the raw contents of an email, provide access to its headers and body.

CLASS METHODS
=============

new
---

```raku
my $eml = Email::Simple.new($raw-mail-text);
```

Creates a `Email::Simple` object given a string containing the raw email text.

```raku
my $new = Email::Simple.create(
  header => [
    ['To', 'mail@example.com'],
    ['From', 'me@example.com'],
    ['Subject', 'test']
  ],
  body => 'This is a test.',
);
```

Creates an `Email::Simple` object given an Array of Arrays with headers, and a body.

create
------

This offers the same functionality as `.new`, but uses a named arguments interface:

  * :header - an Array of Arrays with headers

  * :body - a string with the email's body

  * :header-class - class to handle headers (default: Email::Simple::Header)

INSTANCE METHODS
================

header($name, :$multi)
----------------------

Returns the email header with the name `$name`. If `:$multi` is not passed, then this will return the first header found. If `:$multi` is set, then this will return a list of all headers with the name `$name`.

header-set($name, *@lines)
--------------------------

Sets the header `$name`. Adds one `$name` header for each additional argument passed.

header-names
------------

Returns a list of header names in the email.

headers
-------

Alias of `header-names`

header-pairs
------------

Returns the full header data for an email.

```raku
$eml.header-pairs(); # --> [['Subject', 'test'], ['From', 'me@example.com']]
```

body
----

Returns the mail body. Note that this module does not try to do any decoding, it just returns the body as-is.

body-set($text)
---------------

Sets the mail body to `$text`. Note that this module does not try to properly encode the body.

as-string, Str
--------------

Returns the full raw email, suitable for piping into sendmail.

crlf
----

header-obj
----------

header-obj-set($obj)
--------------------

AUTHOR
======

Andrew Egeler

Source can be located at: https://github.com/raku-community-modules/Email-Simple . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2012 - 2018 Andrew Egeler

Copyright 2019 - 2022, 2024, 2026 Raku Community

All files in this repository are licensed under the terms of Create Commons License; for details please see the LICENSE file

