#!/usr/bin/perl
package Requesting;

use warnings; 					#good practice
use strict;						#good practice
use Data::Dumper;				
use HTTP::Tiny;
use Time::HiRes qw/sleep/;
use JSON qw/decode_json/;
use Moose;


sub request{
	my ($self, $id) = @_;
	my $devolution;
	my $server ='http://resistenciarte.org/api/v1/';
	my $url = $server.$id;
        
    my $headers = { accept => 'application/json' };
    my $attempts //= 0;
    my $http = HTTP::Tiny->new();
    my $response = $http->get($url, {headers => $headers});
    
    if($response->{success}) {
        my $content = $response->{content};
        $devolution = decode_json($content);
        
    }
    
    $attempts++;
    my $reason = $response->{reason};
      if($attempts > 3) {
        warn 'Failure with request '.$reason;
        die "Attempted to submit the URL $url more than 3 times without success";
      }
    my $response_code = $response->{status};
	
	# we were rate limited
	if($response_code == 429) {
		my $sleep_time = $response->{headers}->{'retry-after'};
	 	sleep($sleep_time);
		return rest_request($url, $headers, $attempts);
	}

	return $devolution;
}

1;
