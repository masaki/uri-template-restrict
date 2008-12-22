package # hide from PAUSE
    URI::Template::Restrict::Expansion::prefix;

use Moose;

with 'URI::Template::Restrict::Expansion';

sub expand {
    my ($self, $vars) = @_;

    my $name = $self->vars->[0]->{name};
    return '' unless defined(my $args = $vars->{$name});
    $args = [ $args ] unless ref $args;

    my $prefix = $self->has_arg ? $self->arg : '';
    return join '', map { $prefix . $_ } @$args;
}

no Moose; __PACKAGE__->meta->make_immutable;
