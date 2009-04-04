use inc::Module::Install;
name 'URI-Template-Restrict';
all_from 'lib/URI/Template/Restrict.pm';

requires 'Mouse' => '0.14';
requires 'namespace::clean';
requires 'List::MoreUtils';
requires 'Regexp::Assemble';
requires 'Unicode::Normalize';
requires 'URI';
requires 'URI::Escape';

tests 't/*.t';
test_requires 'Test::More';
test_requires 'Test::UseAllModules';
test_requires 'Test::Deep';
author_tests 'xt';
use_test_base;

auto_set_repository;
auto_include_deps;
WriteAll;
