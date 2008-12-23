package URI::Template::Restrict::Expansion;

use Mouse::Role;

has 'op'   => ( is => 'rw', isa => 'Str' );
has 'arg'  => ( is => 'rw', isa => 'Str', predicate => 'has_arg' );
has 'vars' => ( is => 'rw', isa => 'ArrayRef', auto_deref => 1 );

requires 'process', 'extract';

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
# RFC 3986 - 2. Characters
# ----------------------------------------------------------------------
#   pct-encoded = "%" HEXDIG HEXDIG
#   unreserved  = ALPHA / DIGIT / "-" / "." / "_" / "~"
#   reserved    = gen-delims / sub-delims
#   gen-delims  = ":" / "/" / "?" / "#" / "[" / "]" / "@"
#   sub-delims  = "!" / "$" / "&" / "'" / "(" / ")"
#               / "*" / "+" / "," / ";" / "="
# ----------------------------------------------------------------------
sub parse {
    my $class = shift;

    local $_ = shift;
    return unless tr/{}/{}/ == 2;

    # varname [ "=" vardefault ]
    my $re = '[a-zA-Z0-9][a-zA-Z0-9._\-]*' .
             '(?:=(?:[a-zA-Z0-9\-._~]|(?:%[a-fA-F0-9]{2}))*)?';

    my ($op, $arg, $vars);
    if (/^\{ ($re) \}$/x) {
        # var ( = varname [ "=" vardefault ] )
        $vars = $1;
    }
    elsif (/^\{ - ([a-zA-Z]+) \| (.*?) \| ($re (?:,$re)*) \}$/x) {
        # regex: (?:[:\/?#\[\]\@!\$&'()*+,;=a-zA-Z0-9\-._~]|(?:%[a-fA-F0-9]{2}))*?
        # operator ( = "-" op "|" arg "|" var [ *("," var) ] )
        ($op, $arg, $vars) = ($1, $2, $3);
    }

    # no vars
    confess "unparsable expansion: $_" unless defined $vars;

    my @vars;
    for my $var (split /,/, $vars) {
        my ($name, $default) = split /=/, $var;
        push @vars, { name => $name, default => $default };
    }

    my $impl = join '::', __PACKAGE__, lc(defined $op ? $op : '__subst__');
    Mouse::load_class($impl) or
        confess "unknown expansion operator: $op in $_";

    return $impl->new(
        vars => \@vars,
        defined $op  ? (op  => $op)  : (),
        defined $arg ? (arg => $arg) : (),
    );
}

no Mouse::Role; 1;

=head1 NAME

URI::Template::Restrict::Expansion - Template expansions

=head1 METHODS

=head2 process

=head2 extract

=head1 PROPERTIES

=head2 op

=head2 arg

=head2 vars

=head2 re

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<URI::Template::Restrict>

=cut
