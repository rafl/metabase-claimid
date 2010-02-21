package Metabase::ClaimID;

use Moose;
use JSON::Any;
use MooseX::LazyRequire;
use MooseX::Types::Moose qw(Str);
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
    traits  => [qw(Hash)],
    is      => 'ro',
    # the index file provided by david has a couple of invalid addresses. i
    # suppose that should be fixed.
    #isa     => Map[EmailAddress, Str],
    isa     => Map[Str, Str],
    lazy    => 1,
    builder => '_build_index',
    handles => {
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
    is      => 'ro',
    does    => 'Path::Resolver::Role::Resolver',
    lazy    => 1,
    builder => '_build_resolver',
    handles => {
        _resolve_entry => 'entity_at',
    },
);

sub BUILD {
    my ($self) = @_;
    $self->_index;
    $self->_resolver;
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

sub resolve {
    my ($self, $address) = @_;

    die "No entry for $address"
        unless $self->entry_exists($address);

    my $entry = $self->_resolve_entry($self->_entry_get($address));
    die "No metabase id for $address"
        unless $entry;

    return $entry->content;
}

__PACKAGE__->meta->make_immutable;

1;
