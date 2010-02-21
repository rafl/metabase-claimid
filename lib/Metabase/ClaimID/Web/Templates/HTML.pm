package Metabase::ClaimID::Web::Templates::HTML;

use Template::Declare::Tags;
use namespace::autoclean;

use parent 'Template::Declare';

BEGIN {
    create_wrapper page_wrapper => sub {
        my ($inner, %params) = @_;
        html {
            head { title { 'Metabase ID Claimer' } };
            body { $inner->() };
        };
    };
}

sub page ($&) {
    my ($name, $body) = @_;
    template $name => sub {
        my @args = @_;
        page_wrapper { $body->(@args) };
    };
}

page index => sub {
    my ($self, $vars) = @_;
    h1 { 'Claim your Metabase ID' };
    show('form', $vars);
};

page id_sent => sub {
    my ($self, $vars) = @_;
    h1 { 'Metabase ID sent to ' . $vars->{sent_to} };
};

page not_found => sub {
    my ($self, $vars) = @_;
    h1 { 'No entry found for ' . $vars->{address} };
    p  { 'Do you want to claim another address?' };
    show('form', $vars);
};

page temporary_error => sub {
    my ($self, $vars) = @_;
    h1 { 'Temporary error while trying to send Metabase ID for ' . $vars->{address} };
    p  { 'Please try again later.' };
};

page permanent_error => sub {
    my ($self, $vars) = @_;
    h1 { 'Permanent error while trying to looking up Metabase ID for ' . $vars->{address} };
    p  { 'Please contact ' . $vars->{admin_contact} . ' to resolve this issue.' };
};

private template form => sub {
    my ($self, $vars) = @_;

    form {
        attr { action => $vars->{post_uri}, method => 'post' };

        input {
            attr {
                type  => 'text',
                name  => 'email',
                id    => 'email',
                value => 'Your Email Address',
            };
        };

        input {
            attr {
                type  => 'submit',
                name  => 'submit',
                value => 'Send me my Metabase ID',
            };
        };
    };
};

1;
