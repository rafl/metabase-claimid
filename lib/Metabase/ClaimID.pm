package Metabase::ClaimID;

use Moose;
use JSON::Any;
use Email::MIME::Kit;
use MooseX::LazyRequire;
use MooseX::Types::Moose qw(Str ClassName HashRef);
use MooseX::Types::Structured qw(Map);
use MooseX::Types::Email qw(EmailAddress);
use MooseX::Types::Path::Class qw(File Dir);
use Path::Resolver::Resolver::FileSystem;
use namespace::autoclean;

has _index_file => (
    is            => 'ro',
    isa           => File,
    coerce        => 1,
    lazy_required => 1,
    init_arg      => 'index_file',
);

has _index => (
    traits   => [qw(Hash)],
    is       => 'ro',
    # the index file provided by david has a couple of invalid addresses. i
    # suppose that should be fixed.
    #isa      => Map[EmailAddress, Str],
    isa      => Map[Str, Str],
    lazy     => 1,
    init_arg => 'index',
    builder  => '_build_index',
    handles  => {
        entry_exists => 'exists',
        _entry_get   => 'get',
    },
);

has _data_root => (
    is            => 'ro',
    isa           => Dir,
    coerce        => 1,
    lazy_required => 1,
    init_arg      => 'data_root',
);

has _resolver => (
    is       => 'ro',
    does     => 'Path::Resolver::Role::Resolver',
    lazy     => 1,
    init_arg => 'resolver',
    builder  => '_build_resolver',
    handles  => {
        _resolve_entry => 'entity_at',
    },
);

has _kit_source => (
    is            => 'ro',
    isa           => Dir,
    coerce        => 1,
    lazy_required => 1,
    init_arg      => 'kit_source',
);

has _kit => (
    is => 'ro',
    isa => 'Email::MIME::Kit',
    lazy => 1,
    builder => '_build_kit',
    handles => {
        _assemble_email => 'assemble',
    },
);

has sender_address => (
    is       => 'ro',
    isa      => EmailAddress,
    required => 1,
);

{
    use Moose::Util::TypeConstraints;

    my $tc = subtype as ClassName;
    coerce $tc, from Str, via { Class::MOP::load_class($_); $_ };

    has _transport_class => (
        is       => 'ro',
        isa      => $tc,
        coerce   => 1,
        default  => 'Email::Sender::Transport::Sendmail',
        init_arg => 'transport_class',
        handles  => {
            _create_transport => 'new',
        },
    );

    no Moose::Util::TypeConstraints;
}

has _transport_args => (
    is       => 'ro',
    isa      => HashRef,
    init_arg => 'transport_args',
    default  => sub { +{} },
);

has _transport => (
    is       => 'ro',
    does     => 'Email::Sender::Transport',
    lazy     => 1,
    init_arg => 'transport',
    builder  => '_build_transport',
    handles  => {
        _send_email => 'send',
    },
);

sub BUILD {
    my ($self) = @_;
    for my $attr (qw(_index _resolver _kit _transport)) {
        $self->$attr;
    }
}

sub _build_index {
    my ($self) = @_;
    return JSON::Any->new->decode(scalar $self->_index_file->slurp);
}

sub _build_resolver {
    my ($self) = @_;
    return Path::Resolver::Resolver::FileSystem->new({
        root => $self->_data_root->stringify,
    });
}

sub _build_kit {
    my ($self) = @_;
    return Email::MIME::Kit->new({ source => $self->_kit_source->stringify });
}

sub _build_transport {
    my ($self) = @_;
    return $self->_create_transport($self->_transport_args);
}

sub resolve {
    my ($self, $address) = @_;

    die "No entry for $address"
        unless $self->entry_exists($address);

    my $entry = $self->_resolve_entry($self->_entry_get($address));
    die "No metabase id for $address"
        unless $entry;

    return $entry->content;
}

# gross hack to work around that Email::MIME::Kit currently can't render attachments
around _assemble_email => sub {
    my ($orig, $self, $args) = @_;

    my $body = $self->$orig($args);

    my $attachment = Email::MIME->create(
        attributes => {
            filename     => 'metabase_id.json',
            name         => 'metabase_id.json',
            content_type => 'application/json',
            encoding     => 'base64',
        },
        body => $args->{id},
    );

    my $email = Email::MIME->create(
        header     => [$body->header_obj->header_pairs],
        attributes => { content_type => 'multipart/mixed' },
        parts      => [$body, $attachment],
    );

    return $email;
};

sub send_id {
    my ($self, $address) = @_;
    my $id = $self->resolve($address);

    my $email = $self->_assemble_email({
        address        => $address,
        id             => $id,
        sender_address => $self->sender_address,
    });

    $self->_send_email($email, {
        to   => $address,
        from => $self->sender_address,
    });
}

__PACKAGE__->meta->make_immutable;

1;
