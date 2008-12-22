package # hide from PAUSE
    URI::Template::Restrict::Expansion::join;

use Moose;

with 'URI::Template::Restrict::Expansion';

sub expand {
    my ($self, $vars) = @_;

    my @pairs;
    for my $var (@{ $self->vars }) {
        my ($name, $default) = @{$var}{qw(name default)};
        my $value = exists $vars->{$name} ? $vars->{$name} : $default;
        next unless defined $value;
        push @pairs, join '=', $name, $value;
    }

    return join $self->has_arg ? $self->arg : '', @pairs;
}

no Moose; __PACKAGE__->meta->make_immutable;
