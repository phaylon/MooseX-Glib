use strictures 1;

package MooseX::Glib::Meta::Class::Trait::SubClass;
use Moose::Role;

use Glib;
use Carp                    qw( confess );
use MooseX::Types::Moose    qw( Bool );
use MooseX::Glib::Util      qw( moosified );
use Moose::Util             qw( does_role );

use syntax qw( simple/v2 ql );
use namespace::autoclean;

has is_reified => (
    init_arg    => undef,
    traits      => ['Bool'],
    is          => 'ro',
    isa         => Bool,
    default     => 0,
    handles     => {
        '_set_reified'  => 'set',
    },
);

my $_isnt_foreign = fun ($attr) {
    return not(
        does_role $attr, 'MooseX::Glib::Meta::Attribute::Trait::Foreign',
    );
};

my $_to_property = fun ($attr) {
    return Glib::ParamSpec->scalar(
        $attr->name,
        $attr->name,
        $attr->documentation || '',
        [qw( writable readable )],
    );
};

my $_get_properties = method {
    return [ map {
        $_->$_to_property;
    } grep {
        $_->$_isnt_foreign;
    } map {
        $self->get_attribute($_);
    } $self->get_attribute_list ];
};

method reify {
    my @superclasses = $self->superclasses;
    Glib::Type->register(
        $superclasses[0],
        $self->name,
        properties  => $self->$_get_properties,
        signals     => $self->get_signal_spec,
    );
    $self->_set_reified;
    $self->make_immutable;
    return 1;
}

around make_immutable (%option) {
    return $self->$orig(
        inline_accessors    => 1,
        inline_constructor  => 0,
        inline_destructor   => 0,
        %option,
    );
}

before make_mutable {
    confess sprintf ql!
        Class '%s' has already been reified and cannot be turned back
        into a mutable state
    !, $self->name if $self->is_reified;
}

1;
