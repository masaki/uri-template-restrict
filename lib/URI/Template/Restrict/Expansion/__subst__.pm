package # hide from PAUSE
    URI::Template::Restrict::Expansion::__subst__;

use Mouse;
use URI::Escape qw(uri_unescape);
use namespace::clean -except => ['meta'];

with 'URI::Template::Restrict::Expansion';

sub process {
    my ($self, $vars) = @_;
    my ($name, $default) = @{ $self->vars->[0] }{qw(name default)};
    $default = '' unless defined $default;
    return defined $vars->{$name} ? $vars->{$name} : $default;
}

sub re {
    return '(?:[a-zA-Z0-9\-._~]|(?:%[a-fA-F0-9]{2}))*';
}

sub extract {
    my ($self, $var) = @_;
    my $value = $var eq '' ? undef : uri_unescape($var);
    return ($self->vars->[0]->{name}, $value);
}

no Mouse; __PACKAGE__->meta->make_immutable; 1;
