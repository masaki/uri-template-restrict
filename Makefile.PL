use inc::Module::Install;
name 'URI-Template-Restrict';
all_from 'lib/URI/Template/Restrict.pm';

# requires '';

# install_script '';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'Test::use::ok';
author_tests 'xt';
use_test_base;

auto_include_deps;
WriteAll;
