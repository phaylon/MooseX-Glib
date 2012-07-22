use strictures 1;

package MooseX::Glib::DSL;

use Carp                qw( confess );
use MooseX::Glib::Util  qw( :all );

use syntax qw( simple/v2 ql );
use namespace::clean;

use Sub::Exporter -setup => {
    exports => [qw(
        reify
        extends
        signal
    )],
};

fun reify ($meta) { $meta->reify }

fun signal ($meta, $name, @args) {
    if (@args == 1) {
        $meta->add_signal_override($name, $args[0]);
    }
    else {
        $meta->add_signal($name, @args);
    }
    return 1;
}

fun extends ($meta, @superclasses) {
    confess sprintf ql!
        Class '%s' has more than one superclass, but multiple
        inheritance is not supported by MooseX::Glib
    !, $meta->name if @superclasses > 1;
    $meta->superclasses(moosified $superclasses[0]);
    return 1;
}

1;
