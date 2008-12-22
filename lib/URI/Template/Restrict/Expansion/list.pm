package # hide from PAUSE
    URI::Template::Restrict::Expansion::list;

use Moose;

with 'URI::Template::Restrict::Expansion';

sub expand {
    my ($self, $vars) = @_;

    my $name = $self->vars->[0]->{name};
    return '' unless defined(my $args = $vars->{$name});
    return '' unless ref $args eq 'ARRAY' and @$args > 0;
    return join $self->has_arg ? $self->arg : '', @$args;
}

no Moose; __PACKAGE__->meta->make_immutable;
