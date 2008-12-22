use Test::Base;
use URI::Template::Restrict;

plan tests => 1 * blocks;

filters { vars => ['eval'] };

run {
    my $block    = shift;
    my $template = URI::Template::Restrict->new(template => $block->input);

    my @vars = sort $template->variables;
    is_deeply \@vars => $block->vars, $block->name;
};

__END__
=== unique
--- input: http://example.com/{x}/{y}/{z}
--- vars: [qw(x y z)]

=== sort
--- input: http://example.com/{z}/{y}/{x}
--- vars: [qw(x y z)]

=== multiple
--- input: http://example.com/{x}/{x}/{x}
--- vars: [qw(x)]
