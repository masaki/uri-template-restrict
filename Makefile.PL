use inc::Module::Install;
name 'URI-Template-Restrict';
all_from 'lib/URI/Template/Restrict.pm';

requires 'Moose' => 0.63;
requires 'namespace::clean';
requires 'overload';
requires 'List::MoreUtils';
requires 'Scalar::Util';
requires 'Storable';
requires 'Unicode::Normalize';
requires 'URI';
requires 'URI::Escape';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'Test::use::ok';
author_tests 'xt';
use_test_base;

auto_include_deps;
WriteAll;
