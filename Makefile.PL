use inc::Module::Install;

name     'Path-Resource';
all_from 'lib/Path/Resource.pm';
author   'Robert Krimen <rkrimen@cpan.org>';

build_requires 'Test::More';
build_requires 'Test::Lazy' => '0.03';

requires 'Path::Class';
requires 'Path::Abstract';
requires 'Scalar::Util';
requires 'URI';
requires 'Class::Accessor::Fast';

auto_install;

WriteAll;

