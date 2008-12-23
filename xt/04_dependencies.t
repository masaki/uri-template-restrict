use Test::More;
eval "use Test::Dependencies exclude => ['URI::Template::Restrict']";
plan skip_all => "Test::Dependencies required for testing dependencies" if $@;
ok_dependencies();
