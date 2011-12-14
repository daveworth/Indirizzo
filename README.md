Indirizzo is a simple extraction of the Address class (along with the numbers
and constants handling code) from Geocommon's Geocoder::US gem (available at
[Geocommon's Github](https://github.com/geocommons/geocoder)).  My motivation
for creating this extraction is the dearth of good, and flexible, street address
parsing gems available to the Ruby community.  After digging into Ruby-Toolbox
looking for alternatives I came up with tools based on the Perl
[GEO::StreetAddress::US](http://search.cpan.org/~sderle/Geo-StreetAddress-US-0.99/US.pm)
such as [street\_address](https://github.com/astevens/street_address).  The
street_address gem ended up being much to restrictive for my needs and my
continued searching brought me to the Geocoder::US gem.  Regrettably the
constraints of needing a SQLite3 database for proper geocoding added overhead to
my simple need for parsing addresses that may, or may not, be "complete" or
"well-formed".  Thus Indirizzo was born.
