use strictures 1;

package MooseX::Glib::Meta::Class::Trait::MapForeign;
use Moose::Role;
use Moose::Util qw( with_traits does_role );

use MooseX::Glib::Util  qw( map_type_constraint );
use Glib;
use Carp                qw( confess );

use syntax qw( simple/v2 ql );
use namespace::autoclean;

my $_trait_foreign = 'MooseX::Glib::Meta::Attribute::Trait::Foreign';
my $_attr_foreign = with_traits 'Moose::Meta::Attribute', $_trait_foreign;

my $_perlify = fun ($string) {
    $string =~ s{-}{_}g;
    return $string;
};

method map_from_glib ($class) {
    $self->_map_glib_attributes($class);
    return 1;
}

method _map_glib_attributes ($class) {
    for my $glib_attr ($class->list_properties) {
        my $flags = $glib_attr->{flags};
        my $type  = $glib_attr->{type};
        $self->add_attribute(
            $_attr_foreign->new(
                $glib_attr->{name}->$_perlify,
                isa             => map_type_constraint($type),
                is              => ($flags * 'writable') ? 'rw' : 'ro',
                glib_flags      => $flags,
                glib_type       => $glib_attr->{type},
                documentation   => $glib_attr->{descr} || '',
            ),
        );
    }
    return 1;
}

method get_all_foreign_attributes {
    return grep {
        does_role $_, $_trait_foreign;
    } $self->get_all_attributes;
}

method get_foreign_attribute_list {
    return grep {
        my $attr = $self->get_attribute($_);
        does_role $attr, $_trait_foreign;
    } $self->get_attribute_list;
}

my %_access_method = (
    read  => 'get_value',
    write => 'set_value',
);

my $_is_public_method = fun ($string) {
    return undef
        unless defined $string;
    return undef
        if ref $string;
    return $string !~ m{^_};
};

my %_can_access = (
    read  => fun ($attr) {
        return method ($obj:) { $attr->get_value($obj) }
            if $attr->reader->$_is_public_method
            or $attr->accessor->$_is_public_method;
    },
    write => fun ($attr) {
        return method ($obj: @args) { $attr->set_value($obj, @args) }
            if $attr->writer->$_is_public_method
            or $attr->accessor->$_is_public_method;
    },
);

method _make_property_access ($type) {
    my %access;
    for my $attr ($self->get_all_attributes) {
        $access{$attr->name} = $_can_access{$type}->($attr);
    }
    return method ($instance: $pspec, @args) {
        my $name = $pspec->get_name;
        if (exists $access{$name}) {
            if (my $method = $access{$name}) {
                return $instance->$method(@args);
            }
            else {
                confess sprintf ql!
                    Cannot %s attribute '%s' on instance '%s' directly
                !, $type, $name, $instance;
            }
        }
        else {
            confess sprintf ql!
                Unable to %s unknown attribute '%s' on instance '%s'
            !, $type, $name, $instance;
        }
    };
}

before make_immutable {
    $self->add_method($_ => 'Moose::Object'->can($_)) for qw(
        BUILDARGS
        BUILDALL
    );
    if (my $demolish = $self->get_method('DEMOLISH')) {
        $self->add_method(FINALIZE_INSTANCE => $demolish);
    }
    $self->add_method($_->[0] => $self->_make_property_access($_->[1]))
        for [GET_PROPERTY => 'read'],
            [SET_PROPERTY => 'write'];
    return 1;
}

with qw(
    MooseX::Glib::Meta::Class::Trait::SubClass
);

1;
