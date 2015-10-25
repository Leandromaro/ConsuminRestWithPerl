#!/usr/bin/perl

use LWP::Simple;                # From CPAN
use JSON qw( decode_json );     # From CPAN
use Data::Dumper;               # Perl core module
use strict;                     # Good practice
use warnings;                   # Good practice

my $url = "http://resistenciarte.org/api/v1/node?parameters[type]=autores";
my $json = get($url);
die "Could not get $url!" unless defined $json;

# Decode the entire JSON
my $decoded_json = decode_json( $json );

# Print Json Complete

# print Dumper $decoded_json;

# Print Json's elements by hash tag
my $arrayref = decode_json $json;
foreach my $item( @$arrayref ) { 
    # fields are in $item->{Year}, $item->{Quarter}, etc.
    print $item->{title},
    "\n";   
}      