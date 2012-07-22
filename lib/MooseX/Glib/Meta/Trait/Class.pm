use strictures 1;

package MooseX::Glib::Meta::Trait::Class;
use Moose::Role;

use syntax qw( simple/v2 ql );
use namespace::autoclean;

with qw(
    MooseX::Glib::Meta::Class::Trait::SubClass
    MooseX::Glib::Meta::Trait::Signals
);

1;
