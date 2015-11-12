#!/usr/bin/perl

package Menu;

use strict;
use warnings;

# Menu constructor
sub new {

    # Unpack input arguments
    my $class = shift;
    my (%args) = @_;
    my $title       = $args{title};
    my $choices_ref = $args{choices};
    my $noexit      = $args{noexit};

    # Bless the menu object
    my $self = bless {
        title   => $title,
        choices => $choices_ref,
        noexit  => $noexit,
    }, $class;

    return $self;
}

# Print the menu
sub print {

    # Unpack input arguments
    my $self = shift;
    my $title   =   $self->{title  };
    my @choices = @{$self->{choices}};
    my $noexit  =   $self->{noexit };

    # Print menu
    for (;;) {

        # Print menu title
        print "========================================\n";
        print "    $title\n";
        print "========================================\n";

        # Print menu options
        my $counter = 0;
        for my $choice(@choices) {
            printf "%2d. %s\n", ++$counter, $choice->{text};
        }
        printf "%2d. %s\n", '0', 'Exit' unless $noexit;

        print "\n?: ";

        # Get user input
        chomp (my $input = <STDIN>);

        print "\n";

        # Process input
        if ($input =~ m/\d+/ && $input >= 1 && $input <= $counter) {
            return $choices[$input - 1]{code}->();
        } elsif ($input =~ m/\d+/ && !$input && !$noexit) {
            print "Exiting . . .\n";
            exit 0;
        } else {
            print "Invalid input.\n\n";
        }
    }
}

1;