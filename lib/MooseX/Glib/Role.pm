use strictures 1;

package MooseX::Glib::Role;

use Moose::Role ();
use Moose::Exporter;

my $_trait       = 'MooseX::Glib::Meta::Trait::Role';
my $_to_class    = 'MooseX::Glib::Meta::Role::Application::ToClass';
my $_to_role     = 'MooseX::Glib::Meta::Role::Application::ToRole';
my $_to_instance = 'MooseX::Glib::Meta::Role::Application::ToInstance';

use syntax qw( simple/v2 );
use namespace::clean;

use MooseX::Glib::DSL qw( :all );

method init_meta ($class: %arg) {
    Moose::Role->init_meta(%arg);
    my $meta = Moose::Util::MetaRole::apply_metaroles(
        for             => $arg{for_class},
        role_metaroles  => {
            role                    => [$_trait],
            application_to_class    => [$_to_class],
            application_to_role     => [$_to_role],
            application_to_instance => [$_to_instance],
        },
    );
    return $meta;
}

Moose::Exporter->setup_import_methods(
    with_meta   => [qw( signal )],
    also        => 'Moose::Role',
);

1;
