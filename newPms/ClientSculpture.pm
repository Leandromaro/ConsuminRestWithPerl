package ClientSculpture;
use strict;
use warnings;
use Data::Dumper;
use HTTP::Tiny;
use Time::HiRes qw/sleep/;
use JSON qw/decode_json/;
use Moose;
use Try::Tiny;

##ATTRIBUTES
has name=> (is=>'rw' , isa => 'Str');           #author name
has lat=> (is=>'rw' , isa => 'Str');            #latitude
has long=> (is=>'rw' , isa => 'Str');           #longitude
has author_id=> (is=>'rw', isa=>'Str');         #author ID
has sculp_id => (is=>'rw' , isa => 'Str');      ##sculpture ID



##DONE
sub request_author {
        my $self = shift;
        my $requester = Requesting->new();##it'll use the default parameter
        ##REQUEST TO THE SERVER
        my $json = $requester->request();
        my $name = $self->name;
        ##TREATMENT
        foreach my $item( @$json ) {
                if ($item->{title}=~ /(?i)$name(?i)/) {
                        return $item->{title};
                }
        }
}
##DONE
sub request_image {
        my ($self, $url) = @_;
        ##PARAMETERS
        my $serviceCall = Requesting->new;
        my $sculp_id = "file/".$self->sculp_id;
        my $url_server = $serviceCall->server;
        my $url_full = $url_server.$sculp_id;
        ##REQUEST TO THE SERVER
        my $content = $serviceCall->request("$url_full"); 
        try {
            my $decoded_json = decode_json($content);         
            my $decoded_json = decode_json($content); 
            my $url_image = $decoded_json->{uri_full};
            return $url_image;
        } catch {
            my $anwser = "There is not a sculpture with that id";
            return $anwser;
        };
}


##DONE
sub request_scult_prox{
        my $self = shift;
        ##PARAMETERS
        my $lat = $self->lat;
        my $long = $self->long;
        my $requester = Requesting->new(parameter=>'closest_nodes_by_coord?lat='.$lat.'&lon='.$long);
        ##REQUEST TO THE SERVER
        my $response = $requester->request();
        ##TREATMENT
        my $content = $response->{content};
        my $json = decode_json($content);
        my $count = 0;
        my %temp;
        
         foreach my $item (@$json){
                my $authId = $self->request_auth_scul($item->{nid});
                my $auth = $self->request_auth_id($authId);
                my $image = $self->request_image($item->{nidau});
        
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

##DONE
##given a sculpture id brings info about that sculpture and the author id
sub request_auth_scul {
        my $self = shift;
        my $sculp_id = $self->sculp_id; 
        my $requester = Requesting->new(parameter=>"node/".$sculp_id); 
        ##REQUEST TO THE SERVER
        my $content = $requester->request();
        ##TREATMENT
        my $json = decode_json($content);
        my $ret = $$json{field_autor}{und}[0]{target_id};
        return $ret;

}
##DONE
##given an author ID brigns the author name
sub request_auth_id {
        my $self = shift;
        ##PARAMETERS
        my $author_id = $self->author_id;
        my $requester = Requesting->new(parameter=>'node?parameters[type]=autores');
        my $ret = "undef";
        ##REQUEST TO THE SERVER
        my $content = $requester->request();
        ##TREATMENT
        my $json = decode_json($content);
        foreach my $item (@$json){
                if ($author_id == $item->{nid}){
                        $ret = $item->{title};
                }
        }
        return $ret;
}
1;

