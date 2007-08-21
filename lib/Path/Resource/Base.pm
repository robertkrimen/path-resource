package Path::Resource::Base;

use warnings;
use strict;

=head1 NAME

Path::Resource::Base - A resource base for a Path::Resource object

=cut

use Path::Abstract;
use Path::Class();
use Scalar::Util qw/blessed/;
use URI;

use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors(qw/dir loc uri/);

=over 4

=item Path::Resource::Base->new

=cut

sub new {
	my $self = bless {}, shift;
	local %_ = @_;

	my $dir = $_{dir};
	$dir = Path::Class::dir($dir) unless blessed $dir && $dir->isa("Path::Class::Dir");

    # Extract $uri->path from $uri in order to combine with $loc later
	my $uri = $_{uri};
	$uri = URI->new($uri) unless blessed $uri && $uri->isa("URI");
	my $uri_path = $uri->path;

    # If $loc is relative or ($loc is not defined && $uri_path is empty),
    # this will give us a proper $loc below in any event
    $uri_path = "/" unless length $uri_path;

#   # Set $uri->path to empty, since we'll be using $loc
#   $uri->path('');

	my $loc;
	if (defined $_{loc}) {
		$loc = $_{loc};
		$loc = Path::Abstract->new($loc) unless blessed $loc && $loc->isa("Path::Abstract");
		if ($loc->is_branch) {
            # Combine $loc and $uri_path if $loc is relative
			$loc = Path::Abstract->new($uri_path, $loc->path);
		}
	}
	else {
		$loc = Path::Abstract->new($uri_path);
	}

	$self->dir($dir);
	$self->loc($loc);
	$self->uri($uri);
	return $self;
}

=item $base_rsc->clone

=cut

sub clone {
	my $self = shift;
	return __PACKAGE__->new(dir => $self->dir, loc => $self->loc->clone, uri => $self->uri->clone);
}

=item $base_rsc->uri

=item $base_rsc->loc

=item $base_rsc->dir

=cut

1;
