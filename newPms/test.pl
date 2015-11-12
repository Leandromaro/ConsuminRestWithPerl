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
    { text => 'Go to Menu2',
      code => sub { $menu1->print(); }},
);

# Build menu1
$menu1 = Menu->new(
    title   => 'Menu Options',
    choices => \@menu1_choices,
);


# Print menu1
$menu1->print();