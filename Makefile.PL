use inc::Module::Install;
name 'URI-Template-Restrict';
all_from 'lib/URI/Template/Restrict.pm';

requires 'Mouse' => 0.14;
requires 'Scalar::Util';
requires 'namespace::clean';
requires 'List::MoreUtils';
requires 'Unicode::Normalize';
requires 'URI';
requires 'URI::Escape';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'Test::use::ok';
test_requires 'Test::Deep';
author_tests 'xt';
use_test_base;

auto_include_deps;
WriteAll;
