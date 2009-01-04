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

our $VERSION = '0.02';

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
    return uniq sort map { $_->{name} } map { $_->vars } $self->expansions;
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

    return join '', map { blessed $_ ? $_->process($vars) : $_ } $self->segments;
}

sub extract {
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
        my %var = $_->extract(shift @match);
        %vars = (%vars, %var);
    }

    return %vars;
}

no Mouse; __PACKAGE__->meta->make_immutable; 1;

=head1 NAME

URI::Template::Restrict - restricted URI Templates handler

=head1 SYNOPSIS

    use URI::Template::Restrict;

    my $template = URI::Template::Restrict->new(
        template => 'http://example.com/{foo}'
    );

    my $uri = $template->process(foo => 'y');
    # $uri: "http://example.com/y"

    my %result = $template->extract($uri);
    # %result: (foo => 'y')

=head1 DESCRIPTION

This is a restricted URI Templates handler. URI Templates is described at
L<http://bitworking.org/projects/URI-Templates/>.

This module supports B<draft-gregorio-uritemplate-03> except B<-opt> and
B<-neg> operators.

=head1 METHODS

=head2 new(template => $template)

=head2 process(%vars)

Given a hash of key-value pairs. It will URI escape the values,
substitute them in to the template, and return a L<URI> object.

=head2 process_to_string(%vars)

Processes input like the process method, but doesn't inflate the
result to a L<URI> object.

=head2 extract($uri)

Extracts variables from an uri based on the current template.
Returns a hash with the extracted values.

=head1 PROPERTIES

=head2 template

Returns the original template string.

=head2 variables

Returns a list of unique variable names found in the template.

=head2 expansions

Returns a list of L<URI::Template::Restrict::Expansion> objects found
in the template.

=head1 AUTHOR

NAKAGAWA Masaki E<lt>masaki@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<URI::Template>, L<http://bitworking.org/projects/URI-Templates/>

=cut
