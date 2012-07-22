use strictures 1;

package MooseX::Glib::Meta::Role::Application::Composite::ToRole;
use Moose::Role;

use syntax qw( simple/v2 ql );
use namespace::autoclean;

with qw(
    MooseX::Glib::Meta::Role::Application::Composite
    MooseX::Glib::Meta::Role::Application::ToRole
);

1;
