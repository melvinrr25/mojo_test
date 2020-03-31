package FlyingApp::Controller::Flights;
use FlyingApp::Models::Flight;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub index {
  my $self = shift;
  my $max_results = 5;
  my $q =  { user_id => $self->oid($self->session("id")) };
  my $page = $self->req->query_params->param('page');
  my %data = $self->paginate("flights", $q, $max_results, $page || 1);
  my @flights = @{$data{results}};
  my $pagination = $data{pagination};
  my $skip_pagination = $data{skip_pagination};

  $self->render(
    flights => \@flights, 
    pagination => $pagination, 
    skip_pagination => $skip_pagination
  ); 
}

# action for create
sub create {
  my $self = shift;
  
  my ($valid, $flight) = FlyingApp::Models::Flight->validate($self);

  if (not $valid){
    $self->flash(error => 'Please complete all required fields');
    return $self->render(template => 'flights/form_new', flight => $flight); 
  }

  $self->create_one("flights", $flight);

  $self->flash(success => 'Flight sucessfully saved');
  $self->redirect_to('flights_list');
}

# action for remove
sub remove {
  my $self = shift;
}

# action for update
sub update {
  my $self = shift;
  
  my ($valid, $flight) = FlyingApp::Models::Flight->validate($self);

  if (not $valid){
    $self->flash(error => 'Please complete all required fields');
    return $self->redirect_to('flights_edit', { id =>$self->param('id') });
  }

  $self->update_by_id('flights', $self->param('id'), $flight );

  $self->flash(success => 'Flight sucessfully updated');
  $self->redirect_to('flights_list');
}

# action for update
sub form_new {
  my $self = shift;
  my $flight = {};
  $self->render(flight => $flight); 
}

sub edit {
  my $self = shift;
  my $flight = $self->find_by_id('flights', $self->param('id'));
  $self->render(template => 'flights/form_new', flight => \%$flight); 
}

 
1;
