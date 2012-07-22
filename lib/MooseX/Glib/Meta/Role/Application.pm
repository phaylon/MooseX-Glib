use strictures 1;

package MooseX::Glib::Meta::Role::Application;
use Moose::Role;

use syntax qw( simple/v2 ql );
use namespace::autoclean;

after apply_methods ($role, $other) {
    $self->apply_signals($role, $other);
}

method apply_signals ($role, $other) {
    $other->add_signal($role->get_signal($_))
        for $role->get_signal_list;
    $other->add_signal_override($_, $role->get_signal_override($_))
        for $role->get_signal_override_list;
}

1;
