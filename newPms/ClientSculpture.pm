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
has authorID=> (is=>'rw', isa=>'Str');
has authorName=> (is=>'rw', isa=>'Str');



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
        my $self= shift;
        ##PARAMETERS
        my $id = "/file".$self->id;
        my $requester = Requesting->new(parameter=>$id);
        ##REQUEST TO THE SERVER
        my $json = requester->request() 
        ##TREATMENT
        my $imageUrl = $json->{uri_full},"\n";
        return $imageUrl;

}


##DONE
sub request_scult_prox{
        my $self = shift;
        ##PARAMETERS
        my $lat = $self->lat;
        my $long = $self->long;
        my $requester = Requesting->new(parameter=>'closest_nodes_by_coord?lat='.$lat.'&lon='.$long);
        ##REQUEST TO THE SERVER
        my $response = $requester->request()
        ##TREATMENT
        my $content = $response->{content};
        my $json = decode_json($content);
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

##DONE
sub request_auth_scul {
        my $self = shift;
        my $id_esc = $self->id;
        my $requester = Requesting->new(parameter=>"node/".$id); 
        ##REQUEST TO THE SERVER
        my $content = $requester->request();
        ##TREATMENT
        my $json = decode_json($content);
        my $ret = $$json{field_autor}{und}[0]{target_id};
        return $ret;

}

sub request_auth_id {
        my $self = shift;
        ##PARAMETERS
        my $id = $self->idthorID;
        my $requester = Requesting->new(parameter=>'node?parameters[type]=autores');
        my $ret = "undef";
        ##REQUEST TO THE SERVER
        my $content = $requester->request();
        ##TREATMENT
        my $json = decode_json($content);
        foreach my $item (@$json){
                if ($id == $item->{nid}){
                        $ret = $item->{title};
                }
        }
        return $ret;
}
1;
