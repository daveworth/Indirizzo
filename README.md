# Introduction

Indirizzo is a simple extraction of the Address class (along with the numbers
and constants handling code) from [Geocommons](http://geocommons.com/)'
[Geocoder::US 2.0](https://github.com/geocommons/geocoder) gem.

[![Build Status](https://secure.travis-ci.org/daveworth/Indirizzo.png)](http://travis-ci.org/daveworth/Indirizzo)

## Background

My motivation for creating this extraction is the dearth of high-quality,
flexible, street address parsing gems available to the Ruby community.  After
digging into Ruby-Toolbox looking for alternatives I came up with tools based on
the Perl
[GEO::StreetAddress::US](http://search.cpan.org/~sderle/Geo-StreetAddress-US-0.99/US.pm)
such as [street\_address](https://github.com/astevens/street_address).  The
street_address gem ended up being much to restrictive for my needs and my
continued searching brought me to the Geocoder::US gem.  Regrettably the
constraints of needing a SQLite3 database for proper geocoding added overhead to
my simple needs. I simply need to parse addresses that may, or may not, be
"complete" or "well-formed".  Thus Indirizzo was born.

## Usage

```ruby
require 'Indirizzo'
Indirizzo::Address.new("some address")
```

### Options

`#new` takes a string or a (pre-parsed address) hash as its first parameter and
an options hash.

In the case of a string specifying and address, Indirizzo will do its best to
parse any matter of string, though results can be complicated.  In the cases
where things are complicated the various attributes in Indirizzo do their best
to keep all reasonable answers in an array which you can inspect.  (ex: "1600
Pensylvania Washington", in this case the state is difficult to determine so
both "Pennsylvania" and "Washington" are returned for City and Street)

In the case of the pre-parsed address hash the keys of the
hash be symbols matching the various Address fields in Indirizzo (specifically
`:prenum`, :`number`, `:sufnum`, `:street`, `:city`, `:state`, `:zip`, `:plus4`,
and `:country`)

Currently only one option is supported for the option hash:

* `:expand_streets` - a boolean which determines if "1 First St"'s street parameter
  is expanded into "1 st", "first st", and "one st" or simply left as "first st"

## License

Indirizzo is a direct derivative of [Geocoder::US 2.0](https://github.com/geocommons/geocoder)

Geocoder::US 2.0 was based on earlier work by Schuyler Erle on
a Perl module of the same name. You can find it at
[http://search.cpan.org/~sderle/](http://search.cpan.org/~sderle/).

Geocoder::US 2.0 was written by Schuyler Erle, of Entropy Free LLC,
with the gracious support of FortiusOne, Inc. Please send bug reports,
patches, kudos, etc. to patches at geocoder.us.

Copyright (c) 2009 FortiusOne, Inc.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

