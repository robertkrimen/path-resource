#!perl -T

use Test::More (0 ? (tests => 70) : 'no_plan');
use Test::Lazy qw/try check template/;

use Path::Resource;
use Path::Resource::Base;
my ($rsc, $base, $uri, $loc, $dir, $path);

$rsc = new Path::Resource dir => "/var/dir", uri => "http://hostname/loc";
is($rsc->uri->as_string, "http://hostname/loc");
is($rsc->dir->stringify, "/var/dir");

my $apple_rsc = $rsc->child("apple");
is($apple_rsc->uri->as_string, "http://hostname/loc/apple");
is($apple_rsc->dir->stringify, "/var/dir/apple");

my $banana_txt_rsc = $apple_rsc->child("banana.txt");
is($banana_txt_rsc->uri->as_string, "http://hostname/loc/apple/banana.txt");
is($banana_txt_rsc->file->stringify, "/var/dir/apple/banana.txt");

$rsc = Path::Resource->new(uri => "http://example.com/a", dir => "/home/b/htdocs", path => "xyzzy");
is($rsc->dir->stringify, "/home/b/htdocs/xyzzy");
is($rsc->uri->as_string, "http://example.com/a/xyzzy");

$rsc = Path::Resource->new(uri => "http://example.com/a", dir => "/home/b/htdocs", path => "xyzzy/nothing.txt");
is($rsc->file->stringify, "/home/b/htdocs/xyzzy/nothing.txt");
is($rsc->uri->as_string, "http://example.com/a/xyzzy/nothing.txt");

$rsc = Path::Resource->new(uri => "http://example.com/a", dir => "/home/b/htdocs", loc => "c");
is($rsc->dir->stringify, "/home/b/htdocs");
is($rsc->uri->as_string, "http://example.com/a/c");

$rsc = Path::Resource->new(uri => "http://example.com/a", dir => "/home/b/htdocs", loc => "/g/h");
is($rsc->dir->stringify, "/home/b/htdocs");
is($rsc->uri->as_string, "http://example.com/g/h");

$base = Path::Resource::Base->new(uri => "http://example.com/a", dir => "/home/b/htdocs", loc => "/g/h");
is($base->uri->as_string, "http://example.com/a");
is($base->dir->stringify, "/home/b/htdocs");
is($base->loc->stringify, "/g/h");

ok($base->uri("http://example.org")->isa("URI"));
is($base->uri, "http://example.org");

ok($base->dir("a/b")->isa("Path::Class::Dir"));
is($base->dir, "a/b");

ok($base->loc("g/h/b")->isa("Path::Abstract"));
is($base->loc, "g/h/b");
