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

sub BUILD {
        my $self = shift;
        my $response = shift;
}

sub request_author {
        my $self = shift;
        my $content = $response->{content};
        my $json = decode_json($content);
        my $name = $self->name;

        foreach my $item( @$json ) {
                if ($item->{title}=~ /(?i)$name(?i)/) {
                        return $item->{title};
                }
        }
}

sub request_image {
        my $self= shift;
        my $content = $response->{content};
        my $json = decode_json($content);
        my $imageUrl = $json->{uri_full},"\n";
        return $imageUrl;

}

sub request_scult_prox{

    my ($self,$lat, $long,$response)=@_;
    my $json;

    my $content = $response->{content};
        $json = decode_json($content);



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

    my $self = shift;
    my $id_esc = $self->id;
    my $json;
    my $response = shift;
    my $content = $response->{content};
    $json = decode_json($content);
    my $ret = $$json{field_autor}{und}[0]{target_id};
    return $ret;

}

sub request_auth_id {

    #parametros
    my ($self,$id,$response) = @_;
    my $ret = "undef";
    my $json;
    my $content = $response->{content};
    my $json = decode_json($content);

   foreach my $item (@$json){
        if ($id == $item->{nid}){
            $ret = $item->{title};
        }
    }

    return $ret;

}

1;
