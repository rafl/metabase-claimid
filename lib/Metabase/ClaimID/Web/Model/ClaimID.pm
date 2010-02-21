package Metabase::ClaimID::Web::Model::ClaimID;

use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Adaptor';

__PACKAGE__->config(
    class => 'Metabase::ClaimID',
);

1;
