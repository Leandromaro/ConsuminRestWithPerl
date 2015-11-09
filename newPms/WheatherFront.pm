#!/usr/bin/perl
package WheatherFront;
use Moose;
use Requesting;
use strict;
use warnings;
use JSON qw/decode_json/;
use Data::Dumper;

sub getWheather{
	my $serviceCall = Requesting->new;
	my $content = $serviceCall->request("https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22San%20Fernando%2C%20CHO%2C%20Argentina%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"); 
	my $json = decode_json($content); 
    my $temp = $json->{query}{results}{channel}{item}{condition}{code};
    my $text = $json->{query}{results}{channel}{item}{condition}{text};
    my $date = $json->{query}{results}{channel}{item}{condition}{date};
    
    my %weather = (
    	"date"=>$date,
        "temperatura" => $temp,
        "texto" => $text,
        );
    return %weather;
}
1;
