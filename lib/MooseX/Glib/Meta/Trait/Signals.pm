use strictures 1;

package MooseX::Glib::Meta::Trait::Signals;
use Moose::Role;

use Module::Runtime         qw( use_module );
use MooseX::Glib::Types     qw( Signal );
use MooseX::Types::Moose    qw( HashRef CodeRef );

use syntax qw( simple/v2 ql );
use namespace::autoclean;

has signals => (
    traits  => ['Hash'],
    isa     => HashRef[Signal],
    default => sub { {} },
    handles => {
        has_signals     => 'count',
        get_signal_list => 'keys',
        has_signal      => 'exists',
        get_signal      => 'get',
        _set_signal     => 'set',
        _all_signals    => 'values',
    },
);

has signal_overrides => (
    traits  => ['Hash'],
    isa     => HashRef[CodeRef],
    default => sub { {} },
    handles => {
        has_signal_overrides        => 'count',
        get_signal_override_list    => 'keys',
        has_signal_override         => 'exists',
        get_signal_override         => 'get',
        add_signal_override         => 'set',
    },
);

method signal_metaclass { 'MooseX::Glib::Meta::Signal' }

method add_signal ($name, %arg) {
    my $signal = use_module($self->signal_metaclass)
        ->new(%arg, name => $name);
    $self->_set_signal($signal);
    return $signal;
}

method get_signal_spec {
    return { 
        (map {
            ($_, $self->get_signal($_)->as_signal_spec);
        } $self->get_signal_list),
        (map {
            ($_, $self->get_signal_override($_));
        } $self->get_signal_override_list),
    };
}

1;
