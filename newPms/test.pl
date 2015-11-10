#!/usr/bin/perl

use strict;
use warnings;
use Moose;
use WheatherFront;
use JSON qw/decode_json/;
use Data::Dumper;
use Menu;

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
    { text => 'Choice2',
      code => sub { print "I did something else!\n"; }},
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