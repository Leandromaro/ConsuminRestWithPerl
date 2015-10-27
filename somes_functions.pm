#!/usr/bin/perl
package esculturas.pm

use LWP::Simple;                # From CPAN
use JSON qw( decode_json );     # From CPAN
use Data::Dumper;               # Perl core module
use strict;                     # Good practice
use warnings;                   # Good practice

sub get_scult_prox{
	# paramatros
	my ($lat, $long)=@_;

	my $ret = "undef";

	my %temp;

	my $url = "http://http://resistenciarte.org/api/v1/closest_nodes_by_coord?lat=$lat &lon= $long"

	my $json = get ($url);
	die "Could not get $url!" unless defined $json;

	my $decoded_json = decode_json($json);
	my $count = 0;

	foreach my $item (@$decoded_json){
		my $authId = decode_jason(get_auth_escul($item->{nid}));
		my $auth = decode_jason(get_auth($authId));

		my %sal = { 'sculture' => $item->{node_title},
					'distance' => $item ->{distance},
					'location' => $item->{field_ubicacion}{und}[0]{value},
					'author_id' => $authId,
					'author' => $auth;
		}
		my %temp = {$count => %sal};
	}
 	$ret = JSON->new->utf8->space_after->encode(%temp);

 	return $ret;
}

sub get_auth_scul {
	#parametros
	my ($id_esc) = @_;

	my $url = "http://resistenciarte.org/api/v1/node/$id_esc":

 	my $json = get ($url);
 	die "Could not get $url!" unless defined $json;

	my $decoded_json = decode_json($json);

	my $ret = %%$decoded_json{field_autor}{und}[0]{target_id}

	
	my $ret = JSON->new->utf8->space_after->encode({author => $ret});

	return $ret;

}

sub get_auth {
	#parametros
	my $id = @_;
	my $ret = "undef"

	my $url = "http://resistenciarte.org/api/v1/node?parameters[type]=autores";

	my $json = get ($url);
	die "Could not get $url!" unless defined $json;

	my $decoded_json = decode_json($json);

	foreach my $item (@$decoded_json){
		if ($id == $item->{nid}){
			$ret = $item->{title};
		}
	}

	$ret = JSON->new->utf8->space_after->encode({author_name => $ret});

	return $ret;

}

1;
