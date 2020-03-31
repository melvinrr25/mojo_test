package FlyingApp;
use Mojo::Base 'Mojolicious';
use FlyingApp::Helpers::DBMethodsAbstraction;
use FlyingApp::Helpers::CurrentUser;
use MongoDB;

# This method will run once at server start
sub startup {
  my $self = shift;
  my $mongo_host = 'mongodb://mongo_server/flying';

  my $client = MongoDB::MongoClient->new(host => $mongo_host);
  
  my $db = $client->get_database("flying");
  $self->helper(db => sub { return $db; });

  # Allows to set the signing key as an array,
  # where the first key will be used for all new sessions
  # and the other keys are still used for validation, but not for new sessions.
  $self->secrets(['abc','123']);
  $self->app->sessions->cookie_name('flying_session');

  # Expiration reduced to 10 Minutes
  $self->app->sessions->default_expiration('600');
 
  # Router
  my $r = $self->routes;
  $r->get('/')->name('dashboard')->to('dashboard#index');
  $r->get('/login')->name('login')->to('login#index');
  $r->get('/logout')->name('logout')->to('login#destroy');
  $r->post('/login')->name('login_post')->to('login#create');

	my $authorized = $r->under('/m')->to('login#is_logged_in');
	$authorized->get('flights')->name('flights_list')->to('flights#index');
	$authorized->get('flights/new')->name('flights_new')->to('flights#form_new');
	$authorized->get('flights/:id/edit')->name('flights_edit')->to('flights#edit');
	$authorized->put('flights/:id')->name('flights_update')->to('flights#update');
	$authorized->post('flights')->name('flights_create')->to('flights#create');

	#$authorized->get('/posts/new')->name('posts_new')->to('posts#form_new');

	$self->plugin('FlyingApp::Helpers::DBMethodsAbstraction');
	$self->plugin('FlyingApp::Helpers::CurrentUser');
}

1;
