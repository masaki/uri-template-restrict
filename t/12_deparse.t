use Test::Base;
use Test::Deep;
use URI::Template::Restrict;

plan tests => 1 * blocks;

filters { expected => ['eval'] };

run {
    my $block    = shift;
    my $template = URI::Template::Restrict->new(template => $block->input);

    my %deparse = $template->deparse($block->uri);
    cmp_deeply \%deparse => $block->expected, $block->name;
};

__END__
=== simple
--- input: http://example.com/{foo}/{bar}
--- expected: { foo => 'x', bar => 'y' }
--- uri: http://example.com/x/y

=== escaped
--- input: http://example.com/{foo}/{bar}
--- expected: { foo => ' ', bar => '@' }
--- uri: http://example.com/%20/%40

=== no value
--- input: http://example.com/{foo}/{bar}
--- expected: { foo => 'x', bar => undef }
--- uri: http://example.com/x/

=== no values
--- input: http://example.com/{foo}/{bar}
--- expected: { foo => undef, bar => undef }
--- uri: http://example.com//

=== multiple variables
--- input: http://example.com/{foo}/{foo}
--- expected: { foo => 'x' }
--- uri: http://example.com/x/x

=== simple prefix
--- input: http://example.com{-prefix|/|foo}
--- expected: { foo => 'x' }
--- uri: http://example.com/x

=== empty prefix
--- input: http://example.com{-prefix|/|foo}
--- expected: { foo => undef }
--- uri: http://example.com

=== array prefix
--- input: http://example.com{-prefix|/|foo}
--- expected: { foo => [qw(x y)] }
--- uri: http://example.com/x/y

=== simple suffix
--- input: http://example.com/{-suffix|/|foo}
--- expected: { foo => 'x' }
--- uri: http://example.com/x/

=== empty suffix
--- input: http://example.com/{-suffix|/|foo}
--- expected: { foo => undef }
--- uri: http://example.com/

=== array suffix
--- input: http://example.com/{-suffix|/|foo}
--- expected: { foo => [qw(x y)] }
--- uri: http://example.com/x/y/

=== single join
--- input: http://example.com/?{-join|&|foo}
--- expected: { foo => 'x' }
--- uri: http://example.com/?foo=x

=== multiple join
--- input: http://example.com/?{-join|&|foo,bar,baz,quux}
--- expected: { foo => 'x', bar => 'y', baz => '', quux => undef }
--- uri: http://example.com/?foo=x&bar=y&baz=

=== undefined join
--- input: http://example.com/?{-join|&|quux}
--- expected: { quux => undef }
--- uri: http://example.com/?

=== single list
--- input: http://example.com/{-list|/|foo}
--- expected: { foo => ['y'] }
--- uri: http://example.com/y

=== multiple list
--- input: http://example.com/{-list|/|foo}
--- expected: { foo => [qw(x y z)] }
--- uri: http://example.com/x/y/z

=== empty value list
--- input: http://example.com/{-list|/|foo}
--- expected: { foo => ['x', '', 'z'] }
--- uri: http://example.com/x//z

=== empty array list
--- input: http://example.com/{-list|/|foo}
--- expected: { foo => undef }
--- uri: http://example.com/
