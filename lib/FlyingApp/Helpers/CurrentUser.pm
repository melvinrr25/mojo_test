package FlyingApp::Helpers::CurrentUser;
use base 'Mojolicious::Plugin';

sub current_user {
	my $self = shift;
  return $self->find_by_id("users", $self->session('id'));
}

sub register {
	my ($self, $app) = @_;
	$app->helper(current_user => \&current_user);
}

1;
