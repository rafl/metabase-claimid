package Metabase::ClaimID::Web::View::HTML;

use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TD';

__PACKAGE__->config(
    dispatch_to => ['Metabase::ClaimID::Web::Templates::HTML'],
);

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
