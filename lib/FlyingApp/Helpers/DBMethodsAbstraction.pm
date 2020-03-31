package FlyingApp::Helpers::DBMethodsAbstraction;
use base 'Mojolicious::Plugin';
use Data::Dumper;
use POSIX qw/ceil/;

sub find_by_id {
	my ($self, $table, $id) = @_;
  my $oid = BSON::OID->new(oid => pack('H24', $id));
  my $obj = $self->db->get_collection($table)->find_one({ _id => $oid });
	return $obj;
}

sub update_by_id {
	my ($self, $table, $id, $data) = @_;
  my $oid = BSON::OID->new(oid => pack('H24', $id));
  $self->db->get_collection($table)->update_one({ _id => $oid }, { '$set' => $data });
}

sub create_one {
	my ($self, $table, $data) = @_;
  $self->db->get_collection($table)->insert_one($data);
}

sub find_all {
	my ($self, $table) = @_;
  return $self->db->get_collection($table)->find->all;
}

sub find_by_user_id {
	my ($self, $table, $user_id) = @_;
  my $oid = BSON::OID->new(oid => pack('H24', $user_id));
  return $self->db->get_collection($table)->find({ user_id => $oid })->all;
}

sub paginate {
  my ($self, $table, $condition, $page_size, $page_num) = @_;
  # Calculate number of documents to skip
  my $skips = $page_size * ($page_num - 1);
  # Skip and limit
  my $oid = BSON::OID->new(oid => pack('H24', $user_id));
  # Query the database to get results
  my @results = $self->db->get_collection($table)
    ->find($condition)
    ->skip($skips)
    ->limit($page_size)
    ->all;

  my $counter = $self->db->get_collection($table)->count_documents($condition); 
  my $pages = ceil($counter/$page_size);
  my $pagination = paginator($page_num, $pages);

  return (
    results => \@results,
    pagination => $pagination,
    skip_pagination => ($counter <= $page_size ? 1 : 0),
  );
}

sub oid {
  my ($self, $id) = @_;
  return BSON::OID->new(oid => pack('H24', $id));
}

sub register {
	my ($self, $app) = @_;
	$app->helper(find_by_id => \&find_by_id);
	$app->helper(find_all => \&find_all);
	$app->helper(find_by_user_id => \&find_by_user_id);
	$app->helper(update_by_id => \&update_by_id);
	$app->helper(create_one => \&create_one);
	$app->helper(paginate => \&paginate);
	$app->helper(oid => \&oid);
	$app->helper(count_docs => \&count_docs);
}

sub paginator {

  my ($page, $pages) = @_;

  my $left  = $page - 2;
  my $right = $page + 3;
  my @range;
  my $last;
  my $pagination;

  my $start = sub {
    my $start;
    my $disabled = ($page == 1 ? " disabled" : undef);

    $start = '<div class="pagination-wrapper">';
    $start .= '<ul class="pagination">';
    $start .= "<li class='$disabled'>";
    $start .= '<a href="?page='. ($page - 1) .'"><i>&laquo;</i></a>';
    $start .= "</li>";
    return $start;
  };

  my $current = sub {
    my ($i) = @_;
    my $end;
    my $active = ($page eq $i ? " active" : undef);
    $end = "<li class='$active'>";
    $end .= "<a href='?page=$i'>$i</a>";
    $end .= "</li>";
    return $end;
  };

  my $range = sub {
    my $range;
    $range = '<li class="disabled">';
    $range .= '<a href="#">...</a>';
    $range .= "</li>";

  };

  my $end = sub {
    my $end;
    my $disabled = ($page == $pages ? " disabled" : undef);
    $end = "<li class='$disabled'>";
    $end .= '<a href="?page='. ($page + 1) .'"><i>&raquo;</i></a>';
    $end .= "</li>";
    $end .= '</ul>';
    $end .= '</div>';
    return $end;
  };

  for (my $i = 1; $i <= $pages; $i++) {
    if ($i == 1 || $i == $pages || $i >= $left && $i < $right) {
      push(@range, $i);
    }
  }

  foreach my $i (@range) {
    if ($last) {
    if ($i - $last == 2) {
    $pagination .= &$current($last + 1);
    } elsif ($i - $last != 1) {
    $pagination .= &$range();
    }
    }
    $pagination .= &$current($i);
    $last = $i;
  }

  $pagination = &$start() . $pagination . &$end();
  return $pagination;
}


1;
