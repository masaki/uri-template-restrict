use inc::Module::Install;
name 'URI-Template-Restrict';
all_from 'lib/URI/Template/Restrict.pm';

requires 'Mouse' => 0.14;
requires 'Scalar::Util';
requires 'namespace::clean';
requires 'overload';
requires 'List::MoreUtils';
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
