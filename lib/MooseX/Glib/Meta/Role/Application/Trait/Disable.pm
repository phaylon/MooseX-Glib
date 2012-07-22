use strictures 1;

package MooseX::Glib::Meta::Role::Application::Trait::Disable;
use Moose::Role;

use Carp qw( confess );

use syntax qw( simple/v2 ql );
use namespace::autoclean;

before apply {
    confess q!Illegal MooseX::Glib::Role application!;
}

1;
