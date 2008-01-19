require "Makefile.PL";

__END__

use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Path::Resource',
    license             => 'perl',
    dist_author         => 'Robert Krimen <robertkrimen@gmail.com>',
    dist_version_from   => 'lib/Path/Resource.pm',
    build_requires => {
        'Test::More' => 0,
        'Test::Lazy' => '0.03',
        'JSON::XS' => 0,
    },
    requires => {
        'JSON::XS' => 0,
    	'Path::Class' => 0,
    	'Path::Abstract' => 0,
    	'Scalar::Util' => 0,
    	'URI' => 0,
    	'Class::Accessor::Fast' => 0,
    },
    add_to_cleanup      => [ 'Path-Resource-*' ],
    create_makefile_pl => "traditional",
);

$builder->create_build_script();
