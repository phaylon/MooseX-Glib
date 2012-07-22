use strictures 1;

package MooseX::Glib::Meta::Role::Application::ToInstance;
use Moose::Role;

use syntax qw( simple/v2 ql );
use namespace::autoclean;

with 'MooseX::Glib::Meta::Role::Application::Trait::Disable';

1;
