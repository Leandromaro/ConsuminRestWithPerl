package ClientSculpture;
use strict;
use warnings;
use HTTP::Tiny;
use Time::HiRes qw/sleep/;
use JSON qw/decode_json/;
use Moose;

has name=> (is=>'rw' , isa => 'Str');

sub request_author {
        my $self= shift;
        my $server = 'http://resistenciarte.org/api/v1/';
        my $ping_endpoint = 'node?parameters[type]=autores';
        my $url = $server.$ping_endpoint;
        my $headers = { accept => 'application/json' };
        #my ($url, $headers, $attempts) = @_;
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
  die "Cannot do request because of HTTP reason: '${reason}' (${response_code})";
}
1;
