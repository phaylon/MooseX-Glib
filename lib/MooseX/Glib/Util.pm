use strictures 1;

package MooseX::Glib::Util;

use Moose::Meta::Class;
use Moose::Util         qw( with_traits );
use Carp                qw( confess );

use syntax qw( simple/v2 ql );
use namespace::clean;

use Sub::Exporter -setup => {
    exports => [qw(
        moosified
    )],
};

my $_trait_foreign = 'MooseX::Glib::Meta::Class::Trait::MapForeign';

my $_mapping_meta_class;
my $_mapping_meta = sub {
    return $_mapping_meta_class ||=
        with_traits 'Moose::Meta::Class', $_trait_foreign;
};

my %_class_map;

my $_is_mapped = fun ($class) {
    return $class->can('meta')
        && $class->meta->DOES($_trait_foreign);
};

fun moosified ($original_class) {
    return $original_class
        if $original_class->$_is_mapped;
    return $_class_map{$original_class} ||= do {
        confess sprintf ql{
            The class '%s' is not a subclass of 'Glib::Object' and can
            not be extended by MooseX::Glib
        }, $original_class
            unless $original_class->isa('Glib::Object');
        my $mapped_class = join('::',
            'MooseX::Glib',
            '_MAPPED',
            $original_class,
        );
        my $meta = $_mapping_meta->()->create(
            $mapped_class,
            superclasses => [$original_class],
        );
        $meta->map_from_glib($original_class);
        $meta->reify;
        $mapped_class;
    };
}

1;
