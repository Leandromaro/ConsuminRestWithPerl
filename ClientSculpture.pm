#!/usr/bin/perl
package ClientSculpture;
use strict;
use warnings;
use HTTP::Tiny;
use Time::HiRes qw/sleep/;
use JSON qw/decode_json/;
use Moose;

##ATTRIBUTES
has name=> (is=>'rw' , isa => 'Str');
has id=> (is=>'rw' , isa => 'Str');
has weather=> (is=>'ro', isa=>'HashRef');

##CONSTRUCTOR
sub BUILD {
	my $self = shift;
	my $name = $self->name;
	my $id = $self->id;
	my $weather = $self->weather;
		$weather = request_weather();
}

sub request_author {
        my $self= shift;
        my $server = 'http://resistenciarte.org/api/v1/';
        my $ping_endpoint = 'node?parameters[type]=autores';
        my $url = $server.$ping_endpoint;
        my $headers = { accept => 'application/json' };
        my $attempts //= 0;
        my $http = HTTP::Tiny->new();
        my $response = $http->get($url, {headers => $headers});
        
        if($response->{success}) {
            my $content = $response->{content};
            my $json = decode_json($content);
            	#iterates over the $json
	            my $name = $self->name;
                foreach my $item( @$json ) {
                    # fields are in $item->{Year}, $item->{Quarter}, etc.
                    if ($item->{title}=~ /(?i)$name(?i)/) {
                        return $item->{title};
                    }
                }
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
}

sub request_weather {
	my $self = shift;
        my $url = 'https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22San%20Fernando%2C%20CHO%2C%20Argentina%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys';
        my $headers = { accept => 'application/json' };
        my $attempts //= 0;
        my $http = HTTP::Tiny->new();
        my $response = $http->get($url, {headers => $headers});

        if($response->{success}) {
            my $content = $response->{content};
            my $json = decode_json($content);
            return $json->{query}{results}{channel}{item}{condition};
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
}

sub request_image {
        my $self= shift;
        my $server = 'http://resistenciarte.org/api/v1/file/';
		my $id = $self->id;
		my $url = $server.$id;
        
        my $headers = { accept => 'application/json' };
        my $attempts //= 0;
        my $http = HTTP::Tiny->new();
        my $response = $http->get($url, {headers => $headers});
        
        if($response->{success}) {
            my $content = $response->{content};
            my $json = decode_json($content);
            #print "$_ $json{$_}\n" for (keys %json);
            print $json->{uri_full},"\n";
            #return $json->{uri_full};
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
}

1;
