package # hide from PAUSE
    URI::Template::Restrict::Expansion::join;

use Mouse;
use Regexp::Assemble;
use URI::Escape qw(uri_unescape);
use namespace::clean -except => ['meta'];

with 'URI::Template::Restrict::Expansion';

sub expand {
    my ($self, $vars) = @_;

    my @pairs;
    for my $var ($self->vars) {
        my ($name, $default) = @{$var}{qw(name default)};
        my $value = exists $vars->{$name} ? $vars->{$name} : $default;
        next unless defined $value;
        push @pairs, join '=', $name, $value;
    }

    return join $self->has_arg ? $self->arg : '', @pairs;
}

sub re {
    my $self = shift;

    my $var = '(?:[a-zA-Z0-9\-._~]|(?:%[a-fA-F0-9]{2}))*';
    my $arg = quotemeta($self->arg); 
    my $ra = Regexp::Assemble->new;
    my @vars = $self->vars;
    while (@vars > 0) {
        my $re = sprintf '%s=%s', shift(@vars)->{name}, $var;
        for (@vars) {
            my $name = $_->{name};
            $re .= "(?:${arg}${name}=${var})?";
        }
        $ra->add($re);
    }

    my $re = $ra->as_string;
    return "(?:${re})*";
}

sub deparse {
    my ($self, $var) = @_;

    my %vars = map { ($_->{name}, $_->{default}) } $self->vars;

    my $arg = $self->arg;
    for my $pair (split /$arg/, $var) {
        my ($name, $value) = split /=/, $pair;
        $vars{$name} = uri_unescape($value);
    }

    return %vars;
}

no Mouse; __PACKAGE__->meta->make_immutable; 1;
