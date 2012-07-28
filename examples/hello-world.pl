#!/usr/bin/env perl
use strictures 1;
use Gtk3 -init;

do {
    package Demo::Button;
    use MooseX::Glib;

    extends 'Gtk3::Button';

    has button_label => (is => 'ro', isa => 'Str', required => 1);

    sub BUILD {
        my ($self) = @_;
        $self->label($self->button_label);
    }

    reify;
};

do {
    package Demo::Role::WithQuit;
    use MooseX::Glib::Role;

    signal quit => ();

    sub do_quit { exit }

    sub quit { $_[0]->signal_emit('quit') }
};

do {
    package Demo::Role::WithButton;
    use MooseX::Glib::Role;

    has button => (is => 'ro', lazy => 1, default => sub {
        my $self = shift;
        my $button = Demo::Button->new(button_label => 'Quit!');
        $button->signal_connect(clicked => sub { 
            $self->quit;
        });
        return $button;
    });
};

do {
    package Demo::Window;
    use MooseX::Glib;

    extends 'Gtk3::Window';

    sub BUILD {
        my ($self) = @_;
        $self->add($self->button);
        $self->button->show;
    }

    with qw(
        Demo::Role::WithQuit
        Demo::Role::WithButton
    );

    reify;
};

my $window = Demo::Window->new(
    title => 'Hello World',
);
$window->signal_connect(destroy => sub { $_[0]->quit });
$window->show;

Gtk3::main;
