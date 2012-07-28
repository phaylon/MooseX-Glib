use strictures 1;
use Test::More;

my %_signal;

do {
    package TestRoleA;
    use MooseX::Glib::Role;
    signal test_a => ();
    sub do_test_a { $_signal{a}++ }
};

do {
    package TestRoleB;
    use MooseX::Glib::Role;
    signal test_b => ();
    sub do_test_b { $_signal{b}++ }
};

do {
    package TestOneByOne;
    use MooseX::Glib;
    with $_ for qw( TestRoleA TestRoleB );
    reify;
};

my $one_by_one = TestOneByOne->new;
$one_by_one->signal_emit($_)
    for qw( test_a test_b );
is_deeply \%_signal, { a => 1, b => 1 }, 'signals emitted for one-by-one';

%_signal = ();

do {
    package TestCombined;
    use MooseX::Glib;
    with qw( TestRoleA TestRoleB );
    reify;
};

my $combined = TestCombined->new;
$combined->signal_emit($_)
    for qw( test_a test_b );
is_deeply \%_signal, { a => 1, b => 1 }, 'signals emitted for combined';

done_testing;
