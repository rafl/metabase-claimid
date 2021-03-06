package Metabase::ClaimID::Web::Controller::Root;

use 5.010;
use Moose;
use Try::Tiny;
use MooseX::Types::Moose qw(Str);
use MooseX::Types::Common::String qw(NonEmptySimpleStr);
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::ActionRole' }

__PACKAGE__->config(namespace => '');

has admin_contact => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

sub base : Chained('/') PathPart('') CaptureArgs(0) { }

sub index : Chained('base') PathPart('') Args(0) Does('MatchRequestMethod') Method('GET') {
    my ($self, $ctx) = @_;
    $ctx->stash(post_uri => $ctx->uri_for_action('send_id'));
}

sub send_id : Chained('base') PathPart('') Args(0) Does('MatchRequestMethod') Method('POST') {
    my ($self, $ctx) = @_;

    my $email = $ctx->request->param('email');
    unless (NonEmptySimpleStr->check($email)) {
        $ctx->stash(template => 'index');
        $ctx->detach;
    }

    try {
        $ctx->model('ClaimID')->send_id($email);
        $ctx->stash(template => 'id_sent', sent_to => $email);
    }
    catch {
        $ctx->stash(address => $email);

        when (/^No entry for/) {
            $ctx->response->status(404);
            $ctx->stash(template => 'not_found');
        }
        when (/^No metabase id for/) {
            $ctx->response->status(500);
            $ctx->stash(
                template      => 'permanent_error',
                admin_contact => $self->admin_contact,
            );
        }
        default {
            $ctx->response->status(500);
            $ctx->stash(template => 'temporary_error');
        }
    };
}

sub error_404 : Chained('base') PathPart('') Args {
    my ($self, $ctx) = @_;
    $ctx->response->body( 'Page not found' );
    $ctx->response->status(404);
}

sub end : ActionClass('RenderView') { }

__PACKAGE__->meta->make_immutable;

1;
