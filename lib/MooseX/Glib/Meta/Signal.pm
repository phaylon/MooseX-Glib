use strictures 1;

package MooseX::Glib::Meta::Signal;
use Moose;

use MooseX::Types::Moose    qw( Str ArrayRef CodeRef );
use MooseX::Glib::Types     qw( :all );
use Glib;

use syntax qw( simple/v2 ql );
use namespace::autoclean;

has name => (
    is          => 'ro',
    isa         => Identifier,
    required    => 1,
);

has flags => (
    is          => 'ro',
    isa         => SignalFlags,
    coerce      => 1,
    default     => sub { SignalFlags->coerce(['run-first']) },
);

has param_types => (
    traits      => ['Array'],
    isa         => GlibTypeList,
    coerce      => 1,
    default     => sub { [] },
    handles     => {
        param_types     => 'elements',
        has_param_types => 'count',
    },
);

has class_closure => (
    is          => 'ro',
    isa         => CodeRef | Identifier,
    predicate   => 'has_class_closure',
);

has return_type => (
    is          => 'ro',
    isa         => GlibType,
    coerce      => 1,
    predicate   => 'has_return_type',
);

has accumulator => (
    is          => 'ro',
    isa         => CodeRef,
    predicate   => 'has_accumulator',
);

method as_signal_spec {
    return {
        flags       => $self->flags,
        param_types => [$self->param_types],
        $self->has_class_closure
            ? (class_closure => $self->class_closure)
            : (),
        $self->has_return_type
            ? (return_type => $self->return_type)
            : (),
        $self->has_accumulator
            ? (accumulator => $self->accumulator)
            : (),
    };
};

1;
