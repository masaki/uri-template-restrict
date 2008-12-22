package # hide from PAUSE
    URI::Template::Restrict::Expansion::__subst__;

use Moose;

with 'URI::Template::Restrict::Expansion';

sub expand {
    my ($self, $vars) = @_;
    my ($name, $default) = @{ $self->vars->[0] }{qw(name default)};
    $default = '' unless defined $default;
    return defined $vars->{$name} ? $vars->{$name} : $default;
}

no Moose; __PACKAGE__->meta->make_immutable;
