package URI::Template::Restrict;

use 5.8.1;
use Mouse;
use overload '""' => \&template, fallback => 1;
use List::MoreUtils qw(uniq);
use Storable qw(dclone);
use Unicode::Normalize qw(NFKC);
use URI;
use URI::Escape qw(uri_escape_utf8);
use URI::Template::Restrict::Expansion;
use namespace::clean -except => ['meta'];

our $VERSION = '0.01';

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
    return uniq sort map { $_->{name} } map { @{ $_->{vars} } } $self->expansions;
}

sub parse {
    my ($self, $template) = @_;

    my @segments =
        map { URI::Template::Restrict::Expansion->parse($_) || $_ }
        grep { defined && length } split /(\{.+?\})/, $template;

    $self->segments([@segments]);
}

sub process {
    my $self = shift;
    return URI->new($self->process_to_string(@_));
}

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

    my $vars = dclone((ref $_[0] and ref $_[0] eq 'HASH') ? $_[0] : { @_ });
    for my $value (values %$vars) {
        next if ref $value and ref $value ne 'ARRAY';

        # TODO: check ( unreserved / pct-encoded )
        $_ = uri_escape_utf8(NFKC(defined $_ ? $_ : ''))
            for (ref $value ? @$value : $value);
    }

    return join '', map { blessed $_ ? $_->expand($vars) : $_ } $self->segments;
}

sub deparse {
    my ($self, $uri) = @_;

    my $re = '';
    for ($self->segments) {
        if (blessed $_) {
            $re .= '(' . $_->re . ')';
        }
        else {
            $re .= quotemeta $_;
        }
    }

    return unless my @match = $uri =~ /$re/;
    return unless @match == $self->expansions;

    my %vars;
    for ($self->expansions) {
        my %var = $_->deparse(shift @match);
        %vars = (%vars, %var);
    }

    return %vars;
}

no Mouse; __PACKAGE__->meta->make_immutable; 1;

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
