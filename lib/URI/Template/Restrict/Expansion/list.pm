package # hide from PAUSE
    URI::Template::Restrict::Expansion::list;

use Mouse;
use URI::Escape qw(uri_unescape);
use namespace::clean -except => ['meta'];

with 'URI::Template::Restrict::Expansion';

sub process {
    my ($self, $vars) = @_;

    my $name = $self->vars->[0]->{name};
    return '' unless defined(my $args = $vars->{$name});
    return '' unless ref $args eq 'ARRAY' and @$args > 0;
    return join $self->has_arg ? $self->arg : '', @$args;
}

sub re {
    my $self = shift;

    my $var = '(?:[a-zA-Z0-9\-._~]|(?:%[a-fA-F0-9]{2}))';
    my $arg = quotemeta($self->arg);
    return "(?:${var}*(?:${arg}${var}*)*)*";
}

sub extract {
    my ($self, $var) = @_;

    my $arg = $self->arg;
    my @vars = map { uri_unescape($_) } split /$arg/, $var;
    return ($self->vars->[0]->{name}, @vars > 0 ? \@vars : undef);
}

no Mouse; __PACKAGE__->meta->make_immutable; 1;
