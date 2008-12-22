package URI::Template::Restrict::Expansion;

use Moose;

has 'op'   => ( is => 'rw', isa => 'Str', predicate => 'has_op' );
has 'arg'  => ( is => 'rw', isa => 'Str', predicate => 'has_arg' );
has 'vars' => ( is => 'rw', isa => 'ArrayRef[HashRef]' );
has 'code' => ( is => 'rw', isa => 'CodeRef' );

{
    my $fill = sub {
        my ($self, $vars) = @_;
        my ($name, $default) = @{ $self->vars->[0] }{qw(name default)};
        $default = '' unless defined $default;
        return defined $vars->{$name} ? $vars->{$name} : $default;
    };

    my $code = {
        prefix => sub {
            my ($self, $vars) = @_;

            my $name = $self->vars->[0]->{name};
            return '' unless defined(my $args = $vars->{$name});
            $args = [ $args ] unless ref $args;

            my $prefix = $self->has_arg ? $self->arg : '';
            return join '', map { $prefix . $_ } @$args;
        },
        suffix => sub {
            my ($self, $vars) = @_;

            my $name = $self->vars->[0]->{name};
            return '' unless defined(my $args = $vars->{$name});
            $args = [ $args ] unless ref $args;

            my $suffix = $self->has_arg ? $self->arg : '';
            return join '', map { $_ . $suffix } @$args;
        },
        join => sub {
            my ($self, $vars) = @_;

            my @pairs;
            for my $var (@{ $self->vars }) {
                my ($name, $default) = @{$var}{qw(name default)};
                my $value = exists $vars->{$name} ? $vars->{$name} : $default;
                next unless defined $value;
                push @pairs, join '=', $name, $value;
            }

            return join $self->has_arg ? $self->arg : '', @pairs;
        },
        list => sub {
            my ($self, $vars) = @_;

            my $name = $self->vars->[0]->{name};
            return '' unless defined(my $args = $vars->{$name});
            return '' unless ref $args eq 'ARRAY' and @$args > 0;
            return join $self->has_arg ? $self->arg : '', @$args;
        },
    };

    sub to_code {
        my ($class, $op) = @_;
        return defined $op ? $code->{$op} : $fill;
    }
}

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
    return $_ unless tr/{}//d == 2;

    # varname [ "=" vardefault ]
    my $re = '[a-zA-Z0-9][a-zA-Z0-9._\-]*' .
             '(?:=(?:[a-zA-Z0-9\-._~]|(?:%[a-fA-F0-9]{2}))*)?';

    my ($op, $arg, $vars);
    if (/^$re$/) {
        # var ( = varname [ "=" vardefault ] )
        $vars = $_;
    }
    # (?:[:\/?#\[\]\@!\$&'()*+,;=a-zA-Z0-9\-._~]|(?:%[a-fA-F0-9]{2}))*?
    elsif (/^ - ([a-zA-Z]+) \| (.*?) \| ($re (?:,$re)*) $/x) {
        # operator ( = "-" op "|" arg "|" var [ *("," var) ] )
        ($op, $arg, $vars) = ($1, $2, $3);
    }

    # no vars
    confess "unparsable expansion: $_" unless defined $vars;
    # no op
    confess "unknown expansion operator: $op in {$_}"
        unless my $code = $class->to_code($op);

    my @vars;
    for my $var (split /,/, $vars) {
        my ($name, $default) = split /=/, $var;
        push @vars, { name => $name, default => $default };
    }

    my $self = $class->new(vars => \@vars, code => $code);
    $self->op($op)   if defined $op;
    $self->arg($arg) if defined $arg;

    return $self;
}


sub expand {
    my ($self, $vars) = @_;
    return $self->code->($self, $vars);
}

no Moose; __PACKAGE__->meta->make_immutable;
