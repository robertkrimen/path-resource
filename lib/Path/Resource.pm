package Path::Resource;

use warnings;
use strict;

=head1 NAME

Path::Resource - URI/Path::Class combination.

=head1 VERSION

Version 0.05

=head1 SYNOPSIS

  use Path::Resource;

  # Map a resource on the local disk to a URI.
  # Its (disk) directory is "/var/dir" and its uri is "http://hostname/loc"
  my $rsc = new Path::Resource dir => "/var/dir", uri => "http://hostname/loc";
  # uri: http://hostname/loc 
  # dir: /var/dir

  my $apple_rsc = $rsc->child("apple");
  # uri: http://hostname/loc/apple
  # dir: /var/dir/apple

  my $banana_txt_rsc = $apple_rsc->child("banana.txt");
  # uri: http://hostname/loc/apple/banana.txt
  # file: /var/dir/apple/banana.txt

  my $size = -s $banana_txt_rsc->file;

  redirect($banana_txt_rsc->uri);

=cut

our $VERSION = '0.05';

use Path::Class();
use Path::Resource::Base();
use Path::Abstract;
use Scalar::Util qw/blessed/;
use Carp;
use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors(qw(_path base));

=over 4

=item Path::Resource->new

=cut

sub new {
	my $self = bless {}, shift;
	local %_ = @_;
	my $dir = $_{dir};
	my $file = $_{file};
	my $path = $_{path};
	my $loc = $_{loc};
	my $uri = $_{uri};

	my $base;
	if ($base = $_{base}) {
	}
	else {
		if ($dir && $file && $path) {
			croak "Can't initialize a dir ($dir), a file ($file), and a path ($path) at the same time"
		}
		elsif ($dir && $file) {
			$dir = Path::Class::dir($dir) unless blessed $dir && $dir->isa("Path::Class::Dir");
			$file = Path::Class::file($file) unless blessed $file && $file->isa("Path::Class::File");
			croak "Can't initialize since dir ($dir) does not contain file ($file) unless $dir->subsumes($file)";
			$path = $file->relative($dir);
		}
		elsif ($dir) {
			$dir = Path::Class::dir($dir) unless blessed $dir && $dir->isa("Path::Class::Dir");
		}
		elsif ($file) {
			$dir = Path::Class::dir('/');
		}
		else {
			$dir = Path::Class::dir('/');
		}

        	$base = new Path::Resource::Base(dir => $dir, uri => $uri, loc => $loc);
	}
	$self->base($base);

        $path = Path::Abstract->new($path) unless blessed $path && $path->isa("Path::Abstract");
	$self->_path($path);

	return $self;
}

=item $rsc->path

=item $rsc->path( <part>, [ <part>, ..., <part> ] )

Return a clone of $rsc->path based on $rsc->path and any optional <part> passed through

    my $rsc = Path::Resource->new(path => "b/c");

    # $path is "b/c"
    my $path = $rsc->path;

    # $path is "b/c/d"
    my $path = $rsc->path("d");

=cut

sub path {
	my $self = shift;
    my $path = $self->_path->child(@_);
    return $path;
}

=item $rsc->clone

=item $rsc->clone( <path> )

Return a Path::Resource object that is a copy of $rsc

The optional argument will change (not append) the path of the cloned object

=cut

sub clone {
	my $self = shift;
	my $path = shift || $self->_path->clone;
	return __PACKAGE__->new(base => $self->base->clone, path => $path);
}

=item $rsc->child( <part>, [ <part>, ..., <part> ] )

Return a clone Path::Resource object whose path is the child of $rsc->path

    my $rsc = Path::Resource->new(dir => "/a", path => "b");

    # $rsc->path is "b/c/d.tmp"
    $rsc = $rsc->child("c/d.tmp");

=cut

sub child {
	my $self = shift;
	my $clone = $self->clone($self->_path->child(@_));
	return $clone;
}

=item $rsc->parent

Return a clone Path::Resource object whose path is the parent of $rsc->path

    my $rsc = Path::Resource->new(dir => "/a", path => "b/c");

    # $rsc->path is "b"
    $rsc = $rsc->parent;

    # $rsc->path is ""
    $rsc = $rsc->parent;

    # $dir is "/a/f"
    my $dir = $rsc->parent->parent->dir("f");

=cut

sub parent {
	my $self = shift;
	my $clone = $self->clone($self->_path->parent);
	return $clone;
}

=item $rsc->loc

=item $rsc->loc( <part>, [ <part>, ..., <part> ] )

Return a Path::Abstract object based on the path part of $rsc->base->uri ($rsc->base->loc), $rsc->path, and any optional <part> passed through

    my $rsc = Path::Resource->new(uri => "http://example.com/a", path => "b/c");

    # $loc is "/a/b/c"
    my $loc = $rsc->loc;

    # $dir is "/a/b/c/d.tmp"
    $loc = $rsc->loc("d.tmp");

=cut

sub loc {
	my $self = shift;
	unshift @_, $self->_path unless $self->_path->is_empty;
	return $self->base->loc->child(@_);
}


=item $rsc->uri

=item $rsc->uri( <part>, [ <part>, ..., <part> ] )

Return a URI object based on $rsc->base->uri, $rsc->path, and any optional <part> passed through

    my $rsc = Path::Resource->new(uri => "http://example.com/a", path => "b/c");

    # $uri is "http://example.com/a/b/c"
    my $uri = $rsc->uri;

    # $uri is "http://example.com/a/b/c/d.tmp"
    $uri = $rsc->uri("d.tmp");

    # $uri is "https://example.com/a/b/c/d.tmp"
    $uri->scheme("https");

=cut

sub uri {
	my $self = shift;
	my $uri = $self->base->uri->clone;
	$uri->path($self->loc(@_)->get);
	return $uri;
}

=item $rsc->file

=item $rsc->file( [ <part>, <part>, ..., <part> ] )

Return a Path::Class::File object based on $rsc->base->dir, $rsc->path, and any optional <part> passed through

    my $rsc = Path::Resource->new(dir => "/a", path => "b");
    $rsc = $rsc->child("c/d.tmp");

    # $file is "/a/b/c/d.tmp"
    my $file = $rsc->file;

    # $file is "/a/b/c/d.tmp/e.txt"
    $file = $rsc->file(qw/ e.txt /);

=cut

sub file {
	my $self = shift;
	unshift @_, $self->_path->get unless $self->_path->is_empty;
	return $self->base->dir->file(@_);
}

=item $rsc->dir

=item $rsc->dir( <part>, [ <part>, ..., <part> ] )

Return a Path::Class::Dir object based on $rsc->base->dir, $rsc->path, and any optional <part> passed through

    my $rsc = Path::Resource->new(dir => "/a", path => "b");
    $rsc = $rsc->child("c/d.tmp");

    # $dir is "/a/b/c/d.tmp"
    my $dir = $rsc->file;

    # $dir is "/a/b/c/d.tmp/e.tmp"
    $dir = $rsc->file(qw/ e.tmp /);

=cut

sub dir {
	my $self = shift;
	unshift @_, $self->_path->get unless $self->_path->is_empty;
	return $self->base->dir->subdir(@_);
}


=item $rsc->base

Return the Path::Resource::Base object for $rsc

=back 

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-path-resource at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Path-Resource>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Path::Resource

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Path-Resource>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Path-Resource>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Path-Resource>

=item * Search CPAN

L<http://search.cpan.org/dist/Path-Resource>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Path::Resource
