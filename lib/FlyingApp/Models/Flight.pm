package FlyingApp::Models::Flight;

use strict;
use warnings;
use Data::Dumper;

  

sub validate {
  my ($class, $self) = @_;
  my $valid = 1;
  $valid = 0 if (length $self->req->param('departure_date')) <= 0;
  $valid = 0 if (length $self->req->param('return_date')) <= 0;
  $valid = 0 if (length $self->req->param('country')) <= 0;
  $valid = 0 if (length $self->req->param('adults_number')) <= 0;
  $valid = 0 if (length $self->req->param('service_class')) <= 0;

  my $flight = {
    country => $self->req->param('country'),
    departure_date => $self->req->param('departure_date'),
    return_date => $self->req->param('return_date'),
    service_class => $self->req->param('service_class'),
    adults_number => $self->req->param('adults_number'),
    user_id => BSON::OID->new(oid => pack('H24', $self->session('id'))),
  };

  return ($valid, $flight);
}

1;
