package URI::Template::Restrict;

use 5.8.1;
use Moose;
use overload '""' => \&template, fallback => 1;
use List::MoreUtils qw(uniq);
use Scalar::Util qw(reftype);
use Storable qw(dclone);
use Unicode::Normalize qw(NFKC);
use URI;
use URI::Escape qw(uri_escape_utf8);
use URI::Template::Restrict::Expansion;
use namespace::clean -except => ['meta'];

our $VERSION = '0.01';

around 'new' => sub {
    my ($orig, $self, @args) = @_;
    unshift @args, 'template' if @args == 1; # compat
    $orig->($self, @args);
};

has 'template' => (
    is      => 'rw',
    isa     => 'Str',
    trigger => sub { shift->parse(@_) },
);

has 'segments' => (
    is         => 'rw',
    isa        => 'ArrayRef',
    default    => sub { [] },
    lazy       => 1,
    auto_deref => 1,
);

sub expansions {
    my $self = shift;
    return grep { blessed $_ } $self->segments;
}

sub variables {
    my $self = shift;
    return sort uniq map { keys %{ $_->{vars} } } $self->expansions;
}

sub parse {
    my ($self, $template) = @_;

    my @segments = grep { defined && length } split /(\{.+?\})/, $template;
    for my $segment (@segments) {
        next unless $segment =~ /^\{(.+?)\}$/;
        $segment = $self->parse_expansion($1);
    }

    $self->segments([@segments]);
}

# ----------------------------------------------------------------------
# Draft 03 - 4.1. Variables
# ----------------------------------------------------------------------
# * Some variables may be supplied with default values.
# * The default value must comde from ( unreserved / pct-encoded ).
# ----------------------------------------------------------------------
# Draft 03 - 4.2. Template Expansions
# ----------------------------------------------------------------------
#   op         = 1*ALPHA
#   arg        = *(reserved / unreserved / pct-encoded)
#   var        = varname [ "=" vardefault ]
#   vars       = var [ *("," var) ]
#   varname    = (ALPHA / DIGIT)*(ALPHA / DIGIT / "." / "_" / "-" )
#   vardefault = *(unreserved / pct-encoded)
#   operator   = "-" op "|" arg "|" vars
#   expansion  = "{" ( var / operator ) "}"
# ----------------------------------------------------------------------
# RFC 3986 - Characters
# ----------------------------------------------------------------------
#   pct-encoded = "%" HEXDIG HEXDIG
#   unreserved  = ALPHA / DIGIT / "-" / "." / "_" / "~"
#   reserved    = gen-delims / sub-delims
#   gen-delims  = ":" / "/" / "?" / "#" / "[" / "]" / "@"
#   sub-delims  = "!" / "$" / "&" / "'" / "(" / ")"
#               / "*" / "+" / "," / ";" / "="
# ----------------------------------------------------------------------
sub parse_expansion {
    my ($self, $expansion) = @_;

    my ($op, $arg, $vars) = ('fill', undef, $expansion);
    if ($vars =~ /\|/) {
        ($op, $arg, $vars) = split /\|/, $vars, 3;
    }
    $op =~ s/^\-//;

    my @vars;
    for my $var (split /,/, $vars) {
        my ($name, $default) = split /=/, $var;
        $default = '' unless defined $default;
        push @vars, { name => $name, value => $default };
    }

    return URI::Template::Restrict::Expansion->new(
        op   => $op,
        arg  => $arg,
        vars => \@vars,
    );
}

sub process {
    my $self = shift;
    return URI->new($self->process_to_string(@_));
}

# ----------------------------------------------------------------------
# Draft 03 - 1.2. Design Considerations
# ----------------------------------------------------------------------
# * The reserved characters in a URI Template can only appear in the
#   non-expansion text, or in the argument to an operator.
# * Given the percent-encoding rules for variable values.
# ----------------------------------------------------------------------
# Draft 03 - 4.4. URI Template Substitution
# ----------------------------------------------------------------------
# * MUST convert every variable value into a sequence of characters in
#   ( unreserved / pct-encoded ).
# * Normalizes the string using NFKC, converts it to UTF-8, and then
#   every octet of the UTF-8 string that falls outside of ( unreserved )
#   MUST be percent-encoded.
# ----------------------------------------------------------------------
sub process_to_string {
    my $self = shift;

    my $vars = dclone(reftype $_[0] eq 'HASH' ? $_[0] : { @_ });
    for my $value (values %$vars) {
        next if ref $value and reftype $value ne 'ARRAY';
        $_ = uri_escape_utf8(NFKC(defined $_ ? $_ : ''))
            for (ref $value ? @$value : $value);
    }

    my $uri = join '', map { blessed $_ ? $_->expand($vars) : $_ } $self->segments;
    return $uri;
}

sub deparse {
    # TODO: implementation
}

no Moose; __PACKAGE__->meta->make_immutable;

=head1 NAME

URI::Template::Restrict

=head1 SYNOPSIS

    use URI::Template::Restrict;

=head1 DESCRIPTION

URI::Template::Restrict is

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<URI::Template>, L<http://bitworking.org/projects/URI-Templates/>

=cut
