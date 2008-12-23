package # hide from PAUSE
    URI::Template::Restrict::Expansion::suffix;

use Mouse;
use URI::Escape qw(uri_unescape);
use namespace::clean -except => ['meta'];

with 'URI::Template::Restrict::Expansion';

sub expand {
    my ($self, $vars) = @_;

    my $name = $self->vars->[0]->{name};
    return '' unless defined(my $args = $vars->{$name});
    $args = [ $args ] unless ref $args;

    my $suffix = $self->has_arg ? $self->arg : '';
    return join '', map { $_ . $suffix } @$args;
}

sub re {
    my $self = shift;
    my $arg  = quotemeta($self->arg);
    return "(?:(?:[a-zA-Z0-9\-._~]|(?:%[a-fA-F0-9]{2}))*${arg})*";
}

sub deparse {
    my ($self, $var) = @_;

    my $arg = $self->arg;
    $var =~ s/$arg$//;
    my @vars = map { uri_unescape($_) } split /$arg/, $var;
    return ($self->vars->[0]->{name}, @vars > 1 ? \@vars : @vars ? $vars[0] : undef);
}

no Mouse; __PACKAGE__->meta->make_immutable; 1;
