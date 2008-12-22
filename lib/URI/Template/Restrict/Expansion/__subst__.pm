package # hide from PAUSE
    URI::Template::Restrict::Expansion::__subst__;

use Mouse;

with 'URI::Template::Restrict::Expansion';

sub expand {
    my ($self, $vars) = @_;
    my ($name, $default) = @{ $self->vars->[0] }{qw(name default)};
    $default = '' unless defined $default;
    return defined $vars->{$name} ? $vars->{$name} : $default;
}

no Mouse; __PACKAGE__->meta->make_immutable; 1;
