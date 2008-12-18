use Test::Base 'no_plan';
use URI::Template::Restrict;

my @suites = <t/suites/*.pl>;

for my $file (@suites) {
    my $suite = eval { require $file } or next;
    my $vars  = $suite->{vars};

    for my $test (@{ $suite->{tests} }) {
        my $template = URI::Template::Restrict->new($test->{input});
        is $template->process($vars) => $test->{expected};
    }
}
