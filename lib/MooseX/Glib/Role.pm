use strictures 1;

package MooseX::Glib::Role;

use Moose ();
use Moose::Exporter;

#my $_trait_subclass = 'MooseX::Glib::Meta::Class::Trait::SubClass';

use syntax qw( simple/v2 );
use namespace::clean;

use MooseX::Glib::DSL qw( :all );

method init_meta ($class: %arg) {
    Moose->init_meta(%arg);
    my $meta = Moose::Util::MetaRole::apply_metaroles(
        for             => $arg{for_class},
        class_metaroles => {
            class => [$_trait_subclass],
        },
    );
    extends $meta, 'Glib::Object';
    return $meta;
}

Moose::Exporter->setup_import_methods(
    with_meta       => [qw( signal )],
    also            => 'Moose',
);

1;
