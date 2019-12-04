use Mojo::Base -strict;
use Test::More;
use Mojo::File 'path';
use Mojo::Server;
use Mojo::Util;

sub check_config_ok {
  my $expected_config = shift;

  # allow multiple load_app of same app
  Mojo::Util::_teardown('App::opan');
  my $app = Mojo::Server->new->load_app('./script/opan');
  return is_deeply $app->config, $expected_config, 'config ok';
}

# default
check_config_ok {
  autopin         => undef,
  recurring       => undef,
  upstream_mirror => 'http://www.cpan.org/'
};

# environment
{
  local $ENV{OPAN_AUTOPIN} = 1;
  local $ENV{OPAN_MIRROR} = '/fakepan/';
  local $ENV{OPAN_RECURRING_PULL} = 1;

  check_config_ok {
    autopin         => 1,
    recurring       => 1,
    upstream_mirror => '/fakepan/'
  };
}

# config file
{
  local $ENV{MOJO_HOME} = path('.')->to_abs->child(qw(t fix));
  check_config_ok {
    autopin         => 1,
    recurring       => 0,
    upstream_mirror => 'https://cpan.metacpan.org/'
  };
}

done_testing;
