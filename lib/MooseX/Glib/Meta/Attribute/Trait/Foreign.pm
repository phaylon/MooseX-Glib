use strictures 1;

package MooseX::Glib::Meta::Attribute::Trait::Foreign;
use Moose::Role;

use MooseX::Glib::Types qw( ParamFlags GlibType );

use syntax qw( simple/v2 );
use namespace::autoclean;

has glib_flags => (
    is          => 'ro',
    isa         => ParamFlags,
    required    => 1,
);

has glib_type => (
    is          => 'ro',
    isa         => GlibType,
    required    => 1,
);

1;
