package FlyingApp::Controller::Login;
use Mojo::Base 'Mojolicious::Controller';
use FlyingApp::Helpers::CurrentUser;
use MongoDB::OID;

sub index { 
  my $self = shift;
  if ($self->session('logged_in')) {
    return $self->redirect_to('dashboard'); 
  }
}

sub authenticate {
	my ($c, $email, $password) = @_;
  my $collection = $c->db->get_collection('users');
  my $user = $collection->find_one({ email => $email, password => $password });
	return $user;
}

sub create {
	my $self = shift;
  my $email = $self->req->param('email');
  my $password = $self->req->param('password');
	my $user = authenticate($self, $email, $password); 
	if ($user) {
    my $username = %{$user}{email};
    my $id = %{$user}{_id}->to_string;

		$self->session(logged_in => 1);
		$self->session(username => $username);
		$self->session(id => $id);
		$self->redirect_to('flights_list');

	} else {
    $self->render(template => 'login/index'); 
	}
}

sub destroy {
  my $self = shift;
	$self->session(expires => 1);
  $self->redirect_to('dashboard'); 
}


sub is_logged_in {
	my $self = shift;
	return 1 if $self->session('logged_in');
  $self->redirect_to('login'); 
}

1;
