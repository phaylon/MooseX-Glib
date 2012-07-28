use strictures 1;

# ABSTRACT: Types used by MooseX::Glib

package MooseX::Glib::Types;

use MooseX::Types::Moose qw( :all );
use MooseX::Types::Meta  qw( :all );
use Glib;
use Try::Tiny;

use syntax qw( simple/v2 ql );
use namespace::clean;

use MooseX::Types -declare => [qw(
    Signal
    SignalFlags
    ParamFlags
    GlibType
    GlibTypeList
    Identifier
)];

class_type Signal, { class => 'MooseX::Glib::Meta::Signal' };

my %_flag_type = (
    'Glib::SignalFlags' => SignalFlags,
    'Glib::ParamFlags'  => ParamFlags,
);

for my $glib_flag_type (keys %_flag_type) {
    my $tc = $_flag_type{$glib_flag_type};
    class_type $tc, { class => $glib_flag_type };
    my $flag = enum([
        map $_->{nick}, Glib::Type->list_values($glib_flag_type),
    ]);
    coerce $tc,
        from $flag,
            via { $glib_flag_type->new([$_]) },
        from ArrayRef[$flag],
            via { $glib_flag_type->new($_) };
}

subtype GlibType, as Str, where {
    my $value = $_;
    try { Glib::Type->list_ancestors($value); 1 };
};

coerce GlibType,
    from TypeEquals[Str],   via { 'Glib::String' },
    from TypeEquals[Int],   via { 'Glib::Int' },
    from TypeEquals[Bool],  via { 'Glib::Boolean' },
    from TypeEquals[Any],   via { 'Glib::Scalar' };

my $_glib_tc
    = TypeEquals([Str])
    | TypeEquals([Int])
    | TypeEquals([Bool])
    | TypeEquals([Any]);

subtype GlibTypeList, as ArrayRef[GlibType];

coerce GlibTypeList,
    from ArrayRef[ Str | $_glib_tc ], via {
        [map GlibType->assert_coerce($_), @$_];
    },
    from Str | $_glib_tc, via {
        GlibType->assert_coerce($_);
    };

subtype Identifier, as Str, where {
    length($_) and not(m{\s});
};

1;
