use strictures 1;

package MooseX::Glib::Meta::Trait::Role;
use Moose::Role;

use syntax qw( simple/v2 ql );
use namespace::autoclean;

around composition_class_roles {
    $self->$orig, 'MooseX::Glib::Meta::Role::Composite';
};

with qw(
    MooseX::Glib::Meta::Trait::Signals
);

1;
