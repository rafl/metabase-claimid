package Metabase::ClaimID::Web;

use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

extends 'Catalyst';

__PACKAGE__->config(
    disable_component_resolution_regex_fallback => 1,
);

__PACKAGE__->setup(qw(
    ConfigLoader
    Static::Simple
));

1;
