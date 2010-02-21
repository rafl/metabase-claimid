package Metabase::ClaimID::Web::Templates::HTML;

use Template::Declare::Tags;
use namespace::autoclean;

use parent 'Template::Declare';

BEGIN {
    create_wrapper page => sub {
        my ($inner, %params) = @_;
        html {
            head { title { 'Metabase ID Claimer' } };
            body {
                $inner->();
            };
        };
    };
}

template index => sub {
    my ($self, $vars) = @_;
    page {
        h1 { 'Claim your Metabase ID' };
        show('form', $vars);
    };
};

template id_sent => sub {
    my ($self, $vars) = @_;
    page {
        h1 { 'Metabase ID sent to ' . $vars->{sent_to} };
    };
};

template not_found => sub {
    my ($self, $vars) = @_;
    page {
        h1 { 'No entry found for ' . $vars->{address} };
        p { 'Do you want to claim another address?' };
        show('form', $vars);
    };
};

template temporary_error => sub {
    my ($self, $vars) = @_;
    h1 { 'Temporary error while trying to send Metabase ID for ' . $vars->{address} };
    p { 'Please try again later.' };
};

template permanent_error => sub {
    my ($self, $vars) = @_;
    h1 { 'Permanent error while trying to looking up Metabase ID for ' . $vars->{address} };
    p { 'Please contact ' . $vars->{admin_contact} . ' to resolve this issue.' };
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
