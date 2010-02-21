package Metabase::ClaimID::Web::Controller::Root;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

sub root : Chained('/') PathPart('') CaptureArgs(0) { }

sub base : Chained('root') PathPart('') CaptureArgs(0) { }

sub index : Chained('base') PathPart('') Args(0) { }

sub error_404 : Chained('base') PathPart('') Args {
    my ($self, $ctx) = @_;
    $ctx->response->body( 'Page not found' );
    $ctx->response->status(404);
}

sub end : ActionClass('RenderView') {}

__PACKAGE__->meta->make_immutable;

1;
