#!/usr/bin/env perl
use strictures 1;
use Gtk3 -init;

do {
    package Demo::Getopt;
    use MooseX::Glib;

    extends 'Gtk3::Window';

    with 'MooseX::Getopt';

    reify;
};

my $window = Demo::Getopt->new_with_options;
$window->show;
$window->signal_connect(destroy => sub { exit });

Gtk3::main;
