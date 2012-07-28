use strictures 1;

package MooseX::Glib::Meta::Method::Constructor;
use Moose::Role;

use Glib;
use Data::Dump          qw( pp );
use Carp                qw( confess );
use MooseX::Glib::Util  qw( constructor_method );

use syntax qw( simple/v2 ql );
use namespace::autoclean;

my $_find_foreign = method {
    my %foreign = map {
        ($_->name => 1);
    } $self->associated_metaclass->get_all_foreign_attributes;
    return \%foreign;
};

around _generate_constructor_method {
    my $foreign = $self->$_find_foreign;
    return constructor_method $foreign;
}

around _generate_constructor_method_inline {
    return $self->_generate_constructor_method;
}

1;
