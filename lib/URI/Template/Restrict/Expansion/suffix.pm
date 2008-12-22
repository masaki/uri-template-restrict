package # hide from PAUSE
    URI::Template::Restrict::Expansion::suffix;

use Moose;

with 'URI::Template::Restrict::Expansion';

sub expand {
    my ($self, $vars) = @_;

    my $name = $self->vars->[0]->{name};
    return '' unless defined(my $args = $vars->{$name});
    $args = [ $args ] unless ref $args;

    my $suffix = $self->has_arg ? $self->arg : '';
    return join '', map { $_ . $suffix } @$args;
}

no Moose; __PACKAGE__->meta->make_immutable;
