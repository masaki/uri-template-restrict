package URI::Template::Restrict::Expansion;

use Moose;
use Scalar::Util qw(reftype);
use namespace::clean -except => ['meta'];

has 'op'   => ( is => 'rw', isa => 'Str', default => 'fill', lazy => 1 );
has 'arg'  => ( is => 'rw', isa => 'Maybe[Str]' );
has 'vars' => ( is => 'rw', isa => 'ArrayRef', default => sub { [] }, lazy => 1 );

sub expandable {
    my $self = shift;
    return $self->can('op_' . $self->op);
}

sub expand {
    my ($self, $vars) = @_;
    my $op = 'op_' . $self->op;
    return $self->$op($vars);
}

sub op_fill {
    my ($self, $vars) = @_;

    my ($name, $default) = @{ $self->vars->[0] }{qw(name value)};
    $default = '' unless defined $default;

    return exists $vars->{$name} ? $vars->{$name} : $default;
}

sub op_prefix {
    my ($self, $vars) = @_;

    my $name   = $self->vars->[0]->{name};
    my $prefix = $self->arg;

    return '' unless exists $vars->{$name};
    return '' unless defined $vars->{$name};
    return join '', map { $prefix . $_ }
        reftype $vars->{$name} eq 'ARRAY' ? @{ $vars->{$name} } : ( $vars->{$name} );
}

sub op_suffix {
    my ($self, $vars) = @_;

    my $name   = $self->vars->[0]->{name};
    my $suffix = $self->arg;

    return '' unless exists $vars->{$name};
    return '' unless defined $vars->{$name};
    return join '', map { $_ . $suffix }
        reftype $vars->{$name} eq 'ARRAY' ? @{ $vars->{$name} } : ( $vars->{$name} );
}

sub op_join {
    my ($self, $vars) = @_;

    my @pairs;
    for my $name (map { $_->{name} } @{ $self->vars }) {
        next unless exists $vars->{$name};
        push @pairs, join '=', $name, $vars->{$name};
    }

    return join $self->arg, @pairs;
}

sub op_list {
    my ($self, $vars) = @_;

    my $name = $self->vars->[0]->{name};

    return '' unless exists $vars->{$name};
    return '' unless reftype $vars->{$name} eq 'ARRAY';
    return '' unless @{ $vars->{$name} } > 0;
    return join $self->arg, @{ $vars->{$name} };
}

no Moose; __PACKAGE__->meta->make_immutable;
