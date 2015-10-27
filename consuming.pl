#!/usr/bin/perl
use strict;
use warnings;
use ClientSculpture;
use Data::Dumper;               # Perl core module
use Moose;
use JSON qw/decode_json/;

my $client = ClientSculpture->new(name=>"Alberto");
my %clients = $client->request_author(); 

#my $json = get($client->request_author());
#print $client;
#my $decoded_json = decode_json( $json );
# Print Json Complete
foreach my $key (keys %clients){
    print "$key\n";
}
