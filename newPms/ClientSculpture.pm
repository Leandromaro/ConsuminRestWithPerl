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
has authors => (is=>'rw', isa=>'Maybe[ArrayRef]', writer=>'set_authors', reader=>'get_authors');





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
        my $url = $requester->server.$requester->parameter;
        my $response = $requester->request("$url");
        ##TREATMENT
        try {
                my $json = decode_json($response);
                my $count = 0;
                my %temp;

                foreach my $item (@$json){
                        my $authId = "ee";#$self->request_auth_scul($item->{nid});
                        my $auth = "ffee";#$self->request_auth_id($authId);
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
        } catch {
                my $answer = "there's not nearby sculptures around you\n";
                return $answer;
        }
}


##DONE
##given a sculpture id brings info about that sculpture and the author id
sub request_auth_scul {
        my $self = shift;
        my $sculp_id = $self->sculp_id;
        my $requester = Requesting->new(parameter=>'node/'."$sculp_id");
        ##REQUEST TO THE SERVER
        my $url = $requester->server.$requester->parameter;
        my $content = $requester->request("$url");
        ##TREATMENT
        try {
                my $json = decode_json($content);
                my $ret = $$json{field_autor}{und}[0]{target_id};
                if (!$ret){ 
                	return "Invalid sculpture ID\n";
                	}else {
                		return $ret;
                	}
        } catch {
                my $answer = "invalid sculpture ID\n";
                return $answer;
        }

}

##DONE
##given an author ID brigns the author name
sub request_auth_id {
        my $self = shift;

    	##PARAMETERS
        my $author_id = $self->author_id;
		my $content = request_authors();
		my $ret = "invalid author ID\n";
        ##TREATMENT
        try {
                my $json = decode_json($content);
                foreach my $item (@$json){
                        if ($author_id == $item->{nid}){
                                $ret = $item->{title};
                        }
                }
                return $ret;
        } catch {
                
                return $ret;
        }

}
##DONE
sub request_author {
        my $self = shift;
		my $response = request_authors();
		my $answer "the name received doesn't exist or it's misspelled\n";
        try {
                my $json = decode_json($response);
                my $name = $self->name;
                ##TREATMENT
                foreach my $item( @$json ) {
                        if ($item->{title}=~ /(?i)$name(?i)/) {
                                return $item->{title};
                        }
                }
        } catch {
                return $answer;
        }
}

sub request_authors {
	my $self = shift;
	if (!(my $authors=get_authors())){
		my $requester = Requesting->new(parameter=>'node?parameters[type]=autores');
		my $server = $requester->server;
		my $parameter = $requester->parameter;
		my $url = $server.$parameter;
		my $response = $requester->request("$url");
		#set_authors($response);
		return $response;
	} else{
		my $response = $self->authors;
		return $response;
	}
}


sub all_sculpture{
    my $self = shift;
    ##PARAMETERS
    my $author_id = $self->author_id;
    
    my $requester = Requesting->new(parameter=>'node?parameters[type]=escultura');
    my $url = $requester->server.$requester->parameter;
    my $ret = "undef";
    ##REQUEST TO THE SERVER
    my $content = $requester->request("$url");
    ##TREATMENT
    try {
    my $arrayref = decode_json $content;
        foreach my $item( @$arrayref ) { 
            # fields are in $item->{Year}, $item->{Quarter}, etc.
            
            $self->sculp_id($item->{nid});
            
            my $url_picture= $self->request_image();
            print "========================================\n";
            print "Nombre:", $item->{title},"\n";   
            print "Imagen: $url_picture\n";      
            print "========================================\n";
        }  
    } catch {
        my $answer = "invalid author ID\n";
        print $answer;
    }
         
}


1;

