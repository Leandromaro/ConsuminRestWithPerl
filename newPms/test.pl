#!/usr/bin/perl

use strict;
use warnings;
use Moose;
use WheatherFront;
use JSON qw/decode_json/;
use Data::Dumper;
use Menu;

my $menu1;
my $menu2;

# define menu1 choices
my @menu1_choices = (
    { text => '¿How is the weather?',
      code => sub { 
                    my $wheather = WheatherFront->new;
                    my %hash = $wheather->getWheather();
                    print Dumper(\%hash);
       }},
    { text => 'Choice2',
      code => sub { print "I did something else!\n"; }},
    { text => 'Go to Menu2',
      code => sub { $menu2->print(); }},
);

# define menu2 choices
my @menu2_choices = (
    { text => 'Choice1',
      code => sub { print "I did something in menu 2!\n"; }},
    { text => 'Choice2',
      code => sub { print "I did something else in menu 2!\n"; }},
    { text => 'Go to Menu1',
      code => sub { $menu1->print(); }},
);

# Build menu1
$menu1 = Menu->new(
    title   => 'Menu1',
    choices => \@menu1_choices,
);

# Build menu2
$menu2 = Menu->new(
    title   => 'Menu2',
    choices => \@menu2_choices,
    noexit  => 1,
);

# Print menu1
$menu1->print();