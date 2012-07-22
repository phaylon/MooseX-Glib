use strictures 1;

package MooseX::Glib::Meta::Role::Application::Composite;
use Moose::Role;

use syntax qw( simple/v2 ql );
use namespace::autoclean;

with 'MooseX::Glib::Meta::Role::Application';

around apply_signals ($composite, $other) {
    for my $role (@{ $composite->get_roles }) {
        $self->$orig($role, $other);
    }
}

1;
