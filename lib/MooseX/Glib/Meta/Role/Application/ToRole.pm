use strictures 1;

package MooseX::Glib::Meta::Role::Application::ToRole;
use Moose::Role;

use Moose::Util::MetaRole;

use syntax qw( simple/v2 ql );
use namespace::autoclean;

with 'MooseX::Glib::Meta::Role::Application';

around apply ($role1, $role2) {
    return $self->$orig(
        $role1,
        Moose::Util::MetaRole::apply_metaroles(
            for             => $role2,
            role_metaroles  => {
                application_to_role => [__PACKAGE__],
                application_to_class => [
                    'MooseX::Glib::Meta::Role::Application::ToClass',
                ],
                application_to_instance => [
                    'MooseX::Glib::Meta::Role::Application::ToInstance',
                ],
            },
        ),
    );
}

1;
