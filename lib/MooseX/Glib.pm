use strictures 1;

package MooseX::Glib;

use Moose ();
use Moose::Exporter;

my $_trait       = 'MooseX::Glib::Meta::Trait::Class';
my $_constructor = 'MooseX::Glib::Meta::Method::Constructor';

use syntax qw( simple/v2 );
use namespace::clean;

use MooseX::Glib::DSL qw( :all );

method init_meta ($class: %arg) {
    Moose->init_meta(%arg);
    my $meta = Moose::Util::MetaRole::apply_metaroles(
        for             => $arg{for_class},
        class_metaroles => {
            class       => [$_trait],
            constructor => [$_constructor],
        },
    );
    extends $meta, 'Glib::Object';
    return $meta;
}

Moose::Exporter->setup_import_methods(
    with_meta   => [qw( reify signal extends )],
    also        => 'Moose',
);

1;
