#!/usr/bin/perl
use strict;
use warnings;
use ClientSculpture;
use Data::Dumper;               # Perl core module
use Moose;


my $client = ClientSculpture->new(name=>"Alberto");
my $json = $client;
my $decoded_json = decode_json( $json );

# Print Json Complete

print Dumper $decoded_json;
