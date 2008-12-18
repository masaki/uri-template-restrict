{
    vars => {
        a      => 'fred',
        b      => 'barney',
        c      => 'cheeseburger',
        d      => 'one two three',
        e      => '20% tricky',
        f      => '',
        20     => 'this-is-spinal-tap',
        scheme => 'https',
        p      => 'quote=to+be+or+not+to+be',
        q      => 'hullo#world',
        wilma  => undef,
    },
    tests => [
        {
            input    => 'http://example.org/page1#{a}',
            expected => 'http://example.org/page1#fred',
        },
        {
            input    => 'http://example.org/{a}/{b}/',
            expected => 'http://example.org/fred/barney/',
        },
        {
            input    => 'http://example.com/order/{c}/{c}/{c}/',
            expected => 'http://example.com/order/cheeseburger/cheeseburger/cheeseburger/',
        },
        {
            input    => 'http://example.org/{d}',
            expected => 'http://example.org/one%20two%20three',
        },
        {
            input    => 'http://example.org/{e}',
            expected => 'http://example.org/20%25%20tricky',
        },
        {
            input    => 'http://example.com/{f}/',
            expected => 'http://example.com//',
        },
        {
            input    => '{scheme}://{20}.example.org?date={wilma}&option={a}',
            expected => 'https://this-is-spinal-tap.example.org?date=&option=fred',
        },
        {
            input    => 'http://example.org?{p}',
            expected => 'http://example.org?quote=to+be+or+not+to+be',
        },
        {
            input    => 'http://example.com/{q}',
            expected => 'http://example.com/hullo#world',
        },
    ],
}
