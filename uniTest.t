#!/usr/bin/perl

use strict;
use warnings;
use Test::Simple;
use ClientSculpture;


##Test request_author
my $author = ClientSculpture->new(name=>'Alberto');
my $result = $author->request_author();
ok ($result=~ /[Alberto]/ ,"es correcto");


##Test request_weather
my $url = 'https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22San%20Fernando%2C%20CHO%2C%20Argentina%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys';

my $weather = ClientSculpture->new(name=>'alberto');
my $resul1 = $weather->request_weather();
ok ($resul1 =~ m/[^a-zA-Z0-9]/, "es correcto");
ok ($result =~ /[$url]/, "no es correcto");

my $noName = ClientSculpture->new(name=>'');
$noName = $noName->request_weather();
ok ($noName =~ m/[^a-zA-Z0-9]/, "es correcto");

#Test request_image
my $testImage = ClientSculpture->new(id=>'5877');
my $imageUrl = $testImage->request_image();
ok ($imageUrl =~ m/[^a-zA-Z0-9]/, "es correcto"); ##que deberia devolver?

#Test scult prox
##################################
##########completar###############
##################################

#Test request_auth_scul (given the id sculpture returns the author id)
my $testAuthId = ClientSculpture->new(id=>'5877');
my $authScul = $testAuthId->request_auth_scul();
ok($authScul =~ /^\d+?$/, "es correcto");

#Test request_auth_id (given an author ID returns its name)
my $testAuthName = ClientSculpture->new(id=>'5800');
my $authName = $testAuthName->request_auth_id();
ok($authName = m/[^a-zA-Z0-9]/, "es correcto");
                                                 
