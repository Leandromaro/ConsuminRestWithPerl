#!/usr/bin/perl
package ClientSculpture;
use warnings;
use Data::Dumper;
use HTTP::Tiny;
use Time::HiRes qw/sleep/;
use JSON qw/decode_json/;
use Moose;

##ATTRIBUTES
has name=> (is=>'rw' , isa => 'Str');
has lat=> (is=>'rw' , isa => 'Str');
has long=> (is=>'rw' , isa => 'Str');
has weather=> (is=>'ro', isa=>'HashRef');
has authorID=> (is=>'rw', isa=>'Str');
has authorName=> (is=>'rw', isa=>'Str');

##CONSTRUCTOR
sub BUILD {
    my $weather =request_weather();
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


##RETURNS THE LOCAL WEATHER
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
        my ($self,$id) = @_;
        my $server = 'http://resistenciarte.org/api/v1/file/';
        my $json;
        my $url = $server.$id;
        
        my $headers = { accept => 'application/json' };
        my $attempts //= 0;
        my $http = HTTP::Tiny->new();
        my $response = $http->get($url, {headers => $headers});
        
        if($response->{success}) {
            my $content = $response->{content};
            $json = decode_json($content);
            #print "$_ $json{$_}\n" for (keys %json);
            #print $json->{uri_full},"\n";
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
  return $json->{uri_full};
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
        $json = decode_json($content);
        
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
        my $authId = $self->request_auth_scul($item->{nid});
        my $auth = $self->request_auth_id($authId);
        my $image = $self->request_image($item->{nid});


        my @sal = ( $item->{node_title},
                    $item->{distance},
                    $item->{field_ubicacion}{und}[0]{value},
                    $authId,
                    $auth,
                    $image
        );

        $temp{"$count"} = \@sal;
    }

    return \%temp;
}

sub request_auth_scul {

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
        $json = decode_json($content);
        #return $json;
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

    return $ret;

}

sub request_auth_id {

    #parametros
    my ($self,$id) = @_;
    my $authorsjson;# =$self->authorsjson;
    my $ret;
    my $json;

    #if (!$authorsjson){
        my $url = "http://resistenciarte.org/api/v1/node?parameters[type]=autores";   
        my $headers = { accept => 'application/json' };
        my $attempts //= 0;
        my $http = HTTP::Tiny->new();
        my $response = $http->get($url, {headers => $headers});
        if($response->{success}) {
            my $content = $response->{content};
            $authorsjson = decode_json($content);
            #$self->authorsjson = $authorsjson;
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
            #return rest_request($url, $headers, $attempts);
        }
    #}

    foreach my $item (@$authorsjson){
        if ($id == $item->{nid}){
            $ret = $item->{title};
        }
    }
    
    return $ret;

}

1;

    #Status API Training Shop Blog About Pricing 

