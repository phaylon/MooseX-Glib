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
    package Demo::Window;
    use MooseX::Glib;

    extends 'Gtk3::Window';

    has button => (is => 'ro', lazy => 1, default => sub {
        my $button = Demo::Button->new(button_label => 'Quit!');
        $button->signal_connect(clicked => sub { exit });
        return $button;
    });

    sub BUILD {
        my ($self) = @_;
        $self->add($self->button);
    }

    reify;
};

my $window = Demo::Window->new(
    title => 'Hello World',
);
$window->show_all;

Gtk3::main;
