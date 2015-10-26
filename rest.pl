  #!/usr/bin/perl

  #Create a user agent object
  use LWP::UserAgent;
  my $ua = LWP::UserAgent->new;
  $ua->agent("MyApp/0.1 ");

  #URL
  my $uri = 'http://resistenciarte.org/api/v1/node?parameters[type]=autores';
  
  # Create a request
  my $req = HTTP::Request->new(GET => $uri);
 
  $req->content_type('application/json');
 
  my $res = $ua->request($req);

  # Check the outcome of the response
  if ($res->is_success) {
      print $res->content;
  }
  else {
      print $res->status_line, "\n";
  }
