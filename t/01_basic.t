package Template_Basic;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Test::Mojo;
use utf8;

    my $backup = $ENV{MOJO_MODE} || '';
    
    __PACKAGE__->runtests;
    
    sub basic : Test(9) {
        $ENV{MOJO_MODE} = 'production';
        my $t = Test::Mojo->new('SomeApp');
        $t->get_ok('/exception')
			->status_is(500)
			->content_like(qr{mojolicious_bundled_file});
        $t->get_ok('/not_found')
			->status_is(404)
			->content_like(qr{mojolicious_bundled_file});
        $t->get_ok('/mojolicious_bundled_file/favicon.ico')
			->status_is(200)
			->header_is('Content-Length', 3654)
    }
		{
			package SomeApp;
			use strict;
			use warnings;
			use base 'Mojolicious';
			use lib 't/lib';
			
			sub startup {
				
				my $self = shift;
				
				$ENV{MOJO_REVERSE_PROXY} = 1;
				
				$self->plugin('unmessify_bundle', {prefix => 'mojolicious_bundled_file'});
				
				$self->routes->route('/exception')->to(cb => sub{
					$_[0]->render_exception('a');
				});
				$self->routes->route('/not_found')->to(cb => sub{
					$_[0]->render_not_found();
				});
			}
		}
    
    END {
        $ENV{MOJO_MODE} = $backup;
    }

__END__
