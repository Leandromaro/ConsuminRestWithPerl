#!/usr/bin/perl
use strict;
use warnings;
use ClientSculpture;
use Data::Dumper;               # Perl core module
use Moose;
use JSON qw/decode_json/;

my $client = ClientSculpture->new(name=>"alberto");
my %clients = $client->request_author(); 

	if (%clients){
		# Print Json Complete
		foreach my $key (keys %clients){
			print "The author exits with this name: $key\n";
		}
	}else{
		print "There isn't author with that name \n";

}