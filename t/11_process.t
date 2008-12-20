use Test::Base;
use URI::Template::Restrict;

plan tests => 4 * blocks;

filters { params => ['eval'] };

run {
    my $block    = shift;
    my $name     = $block->name;
    my $template = URI::Template::Restrict->new($block->input);
    my $params   = $block->params;

    my $str = $template->process_to_string(defined $params ? $params : ());
    is $str => $block->expected, "process_to_string: $name";
    ok !ref $str;

    my $uri = $template->process($params ? $params : ());
    is $uri => $block->expected, "process: $name";
    isa_ok $uri => 'URI';
};

__END__
=== simple
--- input: http://example.com/{foo}/{bar}
--- params: { foo => 'x', bar => 'y' }
--- expected: http://example.com/x/y

=== escaped
--- input: http://example.com/{foo}/{bar}
--- params: { foo => ' ', bar => '@' }
--- expected: http://example.com/%20/%40

=== no value
--- input: http://example.com/{foo}/{bar}
--- expected: http://example.com//

=== no valid keys
--- input: http://example.com/{foo}/{bar}
--- params: { baz => 'x', quux => 'y' }
--- expected: http://example.com//

=== multiple variables
--- input: http://example.com/{foo}/{foo}
--- params: { foo => 'x' }
--- expected: http://example.com/x/x
