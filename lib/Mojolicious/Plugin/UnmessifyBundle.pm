package Mojolicious::Plugin::UnmessifyBundle;
use strict;
use warnings;
use Mojo::Base 'Mojolicious::Plugin';
our $VERSION = '0.03';

    sub register {
        my ($self, $app, $args) = @_;
        
        $app->hook(before_dispatch => sub {
            my $c = shift;
            my $parts = $c->req->url->path->parts;
            if ($parts->[0] && $parts->[0] eq $args->{prefix}) {
                shift @$parts;
            }
        });
        
        $app->hook(after_dispatch => sub {
            my $c = shift;
            if ($c->stash('mojo.exception') || $c->stash('mojo.not_found')) {
                my $res = $c->res;
                my $body = $res->body();
                $body =~ s{href=(['"])/}{href=$1/$args->{prefix}/}g;
                $body =~ s{src=(['"])/}{src=$1/$args->{prefix}/}g;
                $body =~ s{url\(/}{url(/$args->{prefix}/}g;
                $res->body($body);
            }
        });
    }

1;

__END__

=head1 NAME

Mojolicious::Plugin::UnmessifyBundle - 

=head1 SYNOPSIS

    sub startup {
        
        my $self = shift;
        
        # Mojolicious
        $self->plugin(unmessify_bundle => {prefix => 'mojolicious-bundle'});
        
        # Mojolicious::Lite
        plugin unmessify_bundle => {prefix => 'mojolicious-bundle'};
    }
    
    # mod_rewrite can be as follows.
    
    RewriteEngine on
    RewriteRule ^(.*(\.(html|htm|xml))|/)$ http://localhost:3000$1 [L,P,QSA]
    RewriteRule ^/mojolicious-bundle(/.+)$ http://localhost:3000$1 [L,P,QSA]

=head1 DESCRIPTION

Deploying mojolicious behind white listed reverse proxy causes bundle files
inaccessible unless each of them is listed. This plugin modifies the
paths as if the files are in a single directory so that the white list can
be a one-liner.

=head1 METHODS

=head2 register

$plugin->register;

Register plugin hooks in L<Mojolicious> application.

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
