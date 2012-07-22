use strictures 1;

package MooseX::Glib::Meta::Role::Composite;
use Moose::Role;

use Moose::Util::MetaRole;

use syntax qw( simple/v2 ql );
use namespace::autoclean;

my $_apply_base  = 'MooseX::Glib::Meta::Role::Application::Composite';
my $_to_class    = "${_apply_base}::ToClass";
my $_to_role     = "${_apply_base}::ToRole";
my $_to_instance = "${_apply_base}::ToInstance";

around apply_params (@args) {
    return Moose::Util::MetaRole::apply_metaroles(
        for             => $self->$orig(@args),
        role_metaroles  => {
            application_to_class    => [$_to_class],
            application_to_role     => [$_to_role],
            application_to_instance => [$_to_instance],
        },
    );
}

1;
