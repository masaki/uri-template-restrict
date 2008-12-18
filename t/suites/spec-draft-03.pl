{
    vars => {
        foo       => "\x{03D3}",
        bar       => 'fred',
        baz       => '10,20,30',
        qux       => [10, 20, 30],
        corge     => [],
        grault    => '',
        garply    => 'a/b/c',
        waldo     => 'ben & jerrys',
        fred      => ['fred', '', 'wilma'],
        plugh     => ["\x{017F}\x{0307}", "\x{0073}\x{0307}"],
        '1-a_b.c' => 200,
    },
    tests => [
        {
            input    => 'http://example.org/?q={bar}',
            expected => 'http://example.org/?q=fred',
        },
        {
            input    => '/{xyzzy}',
            expected => '/',
        },
        {
            input    => 'http://example.org/?{-join|&|foo,bar,xyzzy,baz}',
            expected => 'http://example.org/?foo=%CE%8E&bar=fred&baz=10%2C20%2C30',
        },
        {
            input    => 'http://example.org/?d={-list|,|qux}',
            expected => 'http://example.org/?d=10,20,30',
        },
        {
            input    => 'http://example.org/?d={-list|&d=|qux}',
            expected => 'http://example.org/?d=10&d=20&d=30',
        },
        {
            input    => 'http://example.org/{bar}{bar}/{garply}',
            expected => 'http://example.org/fredfred/a%2Fb%2Fc',
        },
        {
            input    => 'http://example.org/{bar}{-prefix|/|fred}',
            expected => 'http://example.org/fred/fred//wilma',
        },
        # IGNORE -neg
        {
            input    => '{-suffix|:|plugh}',
            expected => '%E1%B9%A1:%E1%B9%A1:',
        },
        {
            input    => '../{waldo}/',
            expected => '../ben%20%26%20jerrys/',
        },
        # IGNORE -opt
        #{
        #    input    => 'telnet:192.0.2.16{-opt|:80|grault}',
        #    expected => 'telnet:192.0.2.16:80',
        #},
        {
            input    => ':{1-a_b.c}:',
            expected => ':200:',
        },
    ],
}
