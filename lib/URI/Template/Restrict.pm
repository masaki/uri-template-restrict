package URI::Template::Restrict;

use 5.8.1;
use Moose;
use overload '""' => \&template, fallback => 1;
use List::MoreUtils qw(uniq);
use Storable qw(dclone);
use Unicode::Normalize qw(NFKC);
use URI;
use URI::Escape qw(uri_escape_utf8);
use namespace::clean -except => ['meta'];

our $VERSION = '0.01';

around 'new' => sub {
    my ($orig, $self, @args) = @_;
    if (@args == 1) {
        # compatibility
        unshift @args, 'template';
    }
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
    return grep { ref } $self->segments;
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

# --------------------------------------------------------------------------------------
# L<http://bitworking.org/projects/URI-Templates/spec/draft-gregorio-uritemplate-03.txt>
# B<4.1. Variables>
# --------------------------------------------------------------------------------------
#     Some variables may be supplied with default values.
#
#     The default value must comde from ( unreserved / pct-encoded ).
#
#     Note that there is no notation for supplying default values to list variables.
# --------------------------------------------------------------------------------------
# L<http://bitworking.org/projects/URI-Templates/spec/draft-gregorio-uritemplate-03.txt>
# B<4.2. Template Expansions>
# --------------------------------------------------------------------------------------
#   op         = 1*ALPHA
#   arg        = *(reserved / unreserved / pct-encoded)
#   var        = varname [ "=" vardefault ]
#   vars       = var [ *("," var) ]
#   varname    = (ALPHA / DIGIT)*(ALPHA / DIGIT / "." / "_" / "-" )
#   vardefault = *(unreserved / pct-encoded)
#   operator   = "-" op "|" arg "|" vars
#   expansion  = "{" ( var / operator ) "}"
# --------------------------------------------------------------------------------------
sub parse_expansion {
    my ($self, $expansion) = @_;

    my ($op, $arg, $vars) = (undef, undef, $expansion);
    if ($vars =~ /\|/) {
        ($op, $arg, $vars) = split /\|/, $vars, 3;
    }

    $vars = { map { /=/ ? (split /=/) : ($_, '') } split /,/, $vars };
    $_ = '' for values %$vars; # fix undef

    return +{
        op   => $op,
        arg  => $arg,
        vars => $vars,
    };
}

sub process {
    my $self = shift;
    return URI->new($self->process_to_string(@_));
}

# --------------------------------------------------------------------------------------
# L<http://bitworking.org/projects/URI-Templates/spec/draft-gregorio-uritemplate-03.txt>
# B<1.2. Design Considerations>
# --------------------------------------------------------------------------------------
#     The final design consideration was control over the placement of
#     reserved characters in the URI generated from a URI Template.
#
#     The reserved characters in a URI Template can only appear
#     in the non-expansion text, or in the argument to an operator,
#     both locations are dictated by the URI Template author.
#
#     Given the percent-encoding rules for variable values this means that
#     the source of all structure, i.e reserved characters, in a URI generated
#     from a URI Template is decided by the URI Template author.
# --------------------------------------------------------------------------------------
# L<http://bitworking.org/projects/URI-Templates/spec/draft-gregorio-uritemplate-03.txt>
# B<4.4. URI Template Substitution>
# --------------------------------------------------------------------------------------
#     Before substitution the template processor MUST convert every variable value
#     into a sequence of characters in ( unreserved / pct-encoded ).
#
#     The template processor does that using the following algorithm:
#     The template processor normalizes the string using NFKC,
#     converts it to UTF-8 [RFC3629], and then every octet of the UTF-8 string
#     that falls outside of ( unreserved ) MUST be percent-encoded,
#     as per [RFC3986], section 2.1.
#
#     For variables that are lists,
#     the above algorithm is applied to each value in the list.
#
#     Requiring that all characters outside of ( unreserved ) be percent encoded means
#     that the only characters outside of ( unreserved ) that will appear
#     in the generated URI-reference will come from outside the template expansions
#     in the URI Template or from the argument of a template expansion.
#
#     This means that the designer of the URI Template
#     determines the placement of reserved characters in the resulting URI,
#     and thus the structure of the resulting generated URI-reference.
# --------------------------------------------------------------------------------------
sub process_to_string {
    my $self = shift;

    my $vars = dclone(ref $_[0] eq 'HASH' ? $_[0] : { @_ });
    for my $value (values %$vars) {
        next if ref $value and ref $value ne 'ARRAY';
        $_ = uri_escape_utf8(NFKC(defined $_ ? $_ : ''))
            for (ref $value ? @$value : $value);
    }

    my $uri = '';
    for my $segment ($self->segments) {
        unless (ref $segment) {
            $uri .= $segment;
        }
        else {
            my $name = shift @{[ keys %{ $segment->{vars} } ]};
            $uri .= $vars->{$name};
        }
    }

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
