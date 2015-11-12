#!/usr/bin/perl

use strict;
use warnings;
use Moose;
use WheatherFront;
use JSON qw/decode_json/;
use Data::Dumper;
use Menu;
use ClientSculpture;
my $menu1;

# define menu1 choices
my @menu1_choices = (
    { text => '¿How is the weather?',
      code => sub { 
                    my $wheather = WheatherFront->new;
                    my %hash = $wheather->getWheather();
                    print Dumper(\%hash),"\n";
                    $menu1->print();
       }},
    { text => 'Get Sculpture image from an id',
      code => sub { 
                  print "Please insert the id from the Sculpture\n";
                  my $id = <>;
                  chomp $id;
                  my $clientSculpture = ClientSculpture->new(sculp_id=>"$id");
                  my $url_text=$clientSculpture->request_image();
                  print $url_text, "\n";
                  $menu1->print();
      }},
    { text => 'Check if an author exists',
      code => sub {
                print "Please insert the author name\n";
                my $name = <>;
                chomp ($name);
                my $clientSculpture = ClientSculpture->new(name=>"$name");
                my $fullName = $clientSculpture->request_author();
                print  "full name: ".$fullName."\n";
                $menu1->print();
      }},
    { text => 'Get nearby sculptures',
        code => sub {
                print "Insert a latitude value\n";
                my $lat = <STDIN>;
                chomp ($lat);
                print "Insert a longitude value\n";
                my $long = <STDIN>;
                chomp ($long);
                my $clientSculpture = ClientSculpture->new(lat=>"$lat", long=>"$long");
                my %hash = $clientSculpture->request_scult_prox();
                print Dumper(\%hash)."\n";
                $menu1->print();
        }},
   { text => 'Get an author using sculpture ID',
        code => sub {
                print "Insert a valid sculpture ID\n";
                my $id = <>;
                chomp ($id);
                my $clientSculpture= ClientSculpture->new(sculp_id=>"$id");
                my $ret = $clientSculpture->request_auth_scul();
                print $ret."\n";
                $menu1->print();
        }},
   { text => 'Get an author name using author ID',
        code =>sub {
                print "Insert a valid author ID\n";
                my $id = <>;
                chomp ($id);
                my $clientSculpture = ClientSculpture->new(auth_id=>"$id");
                my $ret = $clientSculpture->request_auth_id();
                print $ret."\n";
                $menu1->print();
        }},
);


# Build menu1
$menu1 = Menu->new(
    title   => 'Menu Options',
    choices => \@menu1_choices,
);


# Print menu1
$menu1->print();
