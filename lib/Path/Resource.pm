package Path::Resource;

use warnings;
use strict;

=head1 NAME

Path::Resource - URI/Path::Class combination.

=head1 VERSION

Version 0.041

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

our $VERSION = '0.041';

use Path::Class();
use Path::Resource::Base();
use Path::Abstract;
use Scalar::Util qw(blessed);
use Carp;
use base qw/Class::Accessor/;
__PACKAGE__->mk_accessors(qw(path base));

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
	$self->path($path);

	return $self;
}

=item $rsc->file

=cut

sub file {
	my $self = shift;
	unshift @_, $self->path->get unless $self->path->is_empty;
	return $self->base->dir->file(@_);
}

=item $rsc->dir

=cut

sub dir {
	my $self = shift;
	unshift @_, $self->path->get unless $self->path->is_empty;
	return $self->base->dir->subdir(@_);
}

=item $rsc->clone

=cut

sub clone {
	my $self = shift;
	my $path = shift || $self->path->clone;
	return __PACKAGE__->new(base => $self->base->clone, path => $path);
}

=item $rsc->child

=cut

sub child {
	my $self = shift;
	my $clone = $self->clone($self->path->child(@_));
	return $clone;
}

=item $rsc->parent

=cut

sub parent {
	my $self = shift;
	my $clone = $self->clone($self->path->parent);
	return $clone;
}

=item $rsc->loc

=cut

sub loc {
	my $self = shift;
	unshift @_, $self->path unless $self->path->is_empty;
	return $self->base->loc->child(@_);
}


=item $rsc->uri

=cut

sub uri {
	my $self = shift;
	my $uri = $self->base->uri->clone;
	$uri->path($self->loc(@_)->get);
	return $uri;
}

=item $rsc->path

=item $rsc->base

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
