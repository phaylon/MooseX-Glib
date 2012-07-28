use strictures 1;

package MooseX::Glib::Util;

use Glib;
use Moose::Meta::Class;
use Try::Tiny;
use Moose::Util                     qw( with_traits does_role find_meta );
use Carp                            qw( confess );
use Moose::Util::TypeConstraints    qw(
    find_type_constraint
    subtype
    class_type
    where
    as
    enum
);

use syntax qw( simple/v2 ql );
use namespace::clean;

use Sub::Exporter -setup => {
    exports => [qw(
        moosified
        constructor_method
        map_type_constraint
    )],
};

my %_static_type_map = (
    'Glib::String'  => 'Str',
    'Glib::Int'     => 'Int',
    'Glib::Boolean' => 'Bool',
);

my %_isa_type_map = (
    'Glib::Flags'   => fun ($type) {
        my %val = map { ($_->{nick} => 1) } Glib::Type->list_values($type);
        my $tc = subtype as 'ArrayRef[Str]', where {
            not(grep { not $val{$_} } @$_);
        };
        return Moose::Util::TypeConstraints::create_type_constraint_union(
            $tc, class_type($type),
        );
    },
    'Glib::Enum'   => fun ($type) {
        my @vals = map $_->{nick}, Glib::Type->list_values($type);
        my $tc   = enum [@vals];
        return Moose::Util::TypeConstraints::create_type_constraint_union(
            $tc, class_type($type),
        );
    },
);

my %_mapped_classes;

my $_glib_isa = fun ($class, $base) {
    return try {
        return grep { $_ eq $base } Glib::Type->list_ancestors($class);
    };
};

fun map_type_constraint ($glib_type) {
    if (my $tc = $_static_type_map{$glib_type}) {
        return find_type_constraint $tc;
    }
    else {
        return $_mapped_classes{$glib_type}
            if exists $_mapped_classes{$glib_type};
        for my $base (keys %_isa_type_map) {
            if ($glib_type->$_glib_isa($base)) {
                return $_mapped_classes{$glib_type}
                    = $_isa_type_map{$base}->($glib_type);
            }
        }
        if ($glib_type->isa('Glib::Object')) {
            return $_mapped_classes{$glib_type}
                = class_type($glib_type);
        }
    }
    return find_type_constraint 'Any';
}

my $_trait_foreign = 'MooseX::Glib::Meta::Class::Trait::MapForeign';

my $_mapping_meta_class;
my $_mapping_meta = sub {
    return $_mapping_meta_class ||=
        with_traits 'Moose::Meta::Class',
            'MooseX::Glib::Meta::Trait::Class',
            $_trait_foreign;
};

my %_class_map;

my $_is_mapped = fun ($class) {
    return $class->can('meta')
        && does_role $class->meta, $_trait_foreign;
};

fun constructor_method ($foreign) {
    my $split_params = method ($class: $params) {
        my (%glib, %moose);
        ${ $foreign->{$_} ? \%glib : \%moose }{$_} = $params->{$_}
            for keys %$params;
        return \%glib, \%moose;
    };
    return method ($class: @args) {
        confess sprintf ql!
            Constructor 'new' can not be called on instance '%s'
        !, $class if ref $class;
        my $params = $class->BUILDARGS(@args);
        my ($glib_args, $moose_args)
            = $class->$split_params($params);
        my $object = Glib::Object::new($class, %$glib_args);
        $object->tie_properties(1);
        delete $object->{$_}
            for grep not($foreign->{$_}),
                grep not(defined $object->{$_}),
                keys %$object;
        find_meta($class)->new_object({
            %$params,
            __INSTANCE__ => $object,
        });
        return $object;
    };
}

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
