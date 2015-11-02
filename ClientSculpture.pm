#!/usr/bin/perl
package ClientSculpture;
use strict;
use warnings;
use Data::Dumper;
use HTTP::Tiny;
use Time::HiRes qw/sleep/;
use JSON qw/decode_json/;
use Moose;

##ATTRIBUTES
has name=> (is=>'rw' , isa => 'Str');
has id=> (is=>'rw' , isa => 'Str');
has lat=> (is=>'rw' , isa => 'Str');
has long=> (is=>'rw' , isa => 'Str');
has weather=> (is=>'ro', isa=>'HashRef');
has authorID=> (is=>'rw', isa=>'Str');
has authorName=> (is=>'rw', isa=>'Str');

##CONSTRUCTOR
sub BUILD {
	my $self = shift;
	my $name = $self->name;
	my $id = $self->id;
    my $authorName = $self-> authorName;
    my $authorId -> $self-> authorId;
	my $weather = $self->weather;
		$weather = request_weather();
}

##getWeather
sub getWeather {
	my $self = shift;
	return $self->weather;
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
sub request_scult_prox{

    my ($self,$lat, $long)=@_;
    my $json;

    my $url = "http://resistenciarte.org/api/v1/closest_nodes_by_coord?lat=".$lat."&lon=".$long;
    
    my $headers = { accept => 'application/json' };
    my $attempts //= 0;
    my $http = HTTP::Tiny->new();
    my $response = $http->get($url, {headers => $headers});
    
    if($response->{success}) {
        my $content = $response->{content};
        my $json = decode_json($content);
        return $json;
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

    my $count = 0;
    my %temp;

    foreach my $item (@$json){
        my $authId = decode_json(request_auth_scul($item->{nid}));
        my $auth = decode_json(request_auth_id($authId));
        my $image = request_image($item->{nid});


        my %sal = { 'sculture' => $item->{node_title},
                    'distance' => $item ->{distance},
                    'location' => $item->{field_ubicacion}{und}[0]{value},
                    'author_id' => $authId,
                    'author' => $auth,
                    'image' => $image
        };
        %temp = {$count => %sal};
    }
    
    print Dumper(%temp);
    return %temp;
}

sub request_auth_scul {

    #print "here 2";
    #parametros
    my ($self, $id_esc) = @_;
    my $json;

    my $url = "http://resistenciarte.org/api/v1/node/$id_esc";

        
        my $headers = { accept => 'application/json' };
        my $attempts //= 0;
        my $http = HTTP::Tiny->new();
        my $response = $http->get($url, {headers => $headers});
        
        if($response->{success}) {
            my $content = $response->{content};
            my $json = decode_json($content);
            return $json;
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

    my $ret = $$json{field_autor}{und}[0]{target_id};

    print Dumper($ret);
    return $ret;

}

sub request_auth_id {

    print "here 3";
    #parametros
    my ($self,$id) = @_;
    my $ret = "undef";
    my $json;

    my $url = "http://resistenciarte.org/api/v1/node?parameters[type]=autores";

        
        
        my $headers = { accept => 'application/json' };
        my $attempts //= 0;
        my $http = HTTP::Tiny->new();
        my $response = $http->get($url, {headers => $headers});
        
        if($response->{success}) {
            my $content = $response->{content};
            my $json = decode_json($content);
            return $json;
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

    foreach my $item (@$json){
        if ($id == $item->{nid}){
            $ret = $item->{title};
        }
    }

    print Dumper($ret);
    return $ret;

}

1;

    #Status API Training Shop Blog About Pricing 

