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
    { text => 'All the Sculpture',
      code => sub { 
                  my $clientSculpture = ClientSculpture->new;
                  my %hash = $clientSculpture->all_sculpture();
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
);


# Build menu1
$menu1 = Menu->new(
    title   => 'Menu Options',
    choices => \@menu1_choices,
);


# Print menu1
$menu1->print();
