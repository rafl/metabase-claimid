use inc::Module::Install;

name 'Metabase-ClaimID';
all_from 'lib/Metabase/ClaimID.pm';

requires 'Catalyst::Runtime' => '5.8002';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General';
test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
WriteAll;
