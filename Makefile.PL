use inc::Module::Install;

name 'Metabase-ClaimID';
all_from 'lib/Metabase/ClaimID.pm';

requires 'Catalyst::Action::RenderView';
requires 'Catalyst::ActionRole::MatchRequestMethod';
requires 'Catalyst::Controller::ActionRole';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Runtime' => '5.8002';
requires 'Catalyst::View::TD';
requires 'Config::General';
requires 'Email::MIME::Kit';
requires 'JSON::Any';
requires 'Moose' => '0.90';
requires 'MooseX::LazyRequire';
requires 'MooseX::Types';
requires 'MooseX::Types::Common';
requires 'MooseX::Types::Email';
requires 'MooseX::Types::LoadableClass';
requires 'MooseX::Types::Path::Class';
requires 'MooseX::Types::Structured';
requires 'Path::Resolver';
requires 'Try::Tiny';
requires 'namespace::autoclean';
requires 'parent';
requires 'perl' => '5.010000';

test_requires 'Test::More' => '0.88';

catalyst;

install_script glob('script/*.pl');
WriteAll;
