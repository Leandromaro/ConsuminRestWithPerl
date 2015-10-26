  #!/usr/bin/perl

  #Create a user agent object
  use LWP::UserAgent;
  #my $user_agent = LWP::UserAgent::JSON->new;
  my $ua = LWP::UserAgent->new;
  #my $ua = LWP::UserAgent::JSON->new;
  $ua->agent("MyApp/0.1 ");

  #URL
  my $uri = 'http://resistenciarte.org/api/v1/node?parameters[type]=autores';
  
  # Create a request
  
  #my $json = '{"username":"foo","password":"bar"}';

  my $req = HTTP::Request->new(GET => $uri);
  #my $req = HTTP::Request::JSON->new(GET => $uri);
  #$req->header( 'Content-Type' => 'application/json' );
  $req->content_type('application/json');
  #$req->content('query=libwww-perl&mode=dist');
  $req->content($json);
  # Pass request to the user agent and get a response back
  my $res = $ua->request($req);

  # Check the outcome of the response
  if ($res->is_success) {
      print $res->content;
  }
  else {
      print $res->status_line, "\n";
  }
