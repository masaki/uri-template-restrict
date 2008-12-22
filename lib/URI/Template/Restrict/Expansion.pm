package URI::Template::Restrict::Expansion;

use Mouse::Role;

has 'op'   => ( is => 'rw', isa => 'Str', predicate => 'has_op' );
has 'arg'  => ( is => 'rw', isa => 'Str', predicate => 'has_arg' );
has 'vars' => ( is => 'rw', isa => 'ArrayRef' );

requires 'expand';

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
