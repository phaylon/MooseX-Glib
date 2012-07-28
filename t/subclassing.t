use strictures 1;
use Test::More;
use Test::Fatal;

do {
    package TestBase;
    use MooseX::Glib;
    use MooseX::Types::Moose qw( Any );
    signal foo => (return_type => Any, flags => 'run-last');
    has attr => (is => 'rw');
    sub do_foo { 23 }
    sub foo { $_[0]->signal_emit('foo') }
    reify;
};

do {
    my $obj = TestBase->new(attr => 17);
    is $obj->foo, 23, 'signal on base';
    is $obj->attr, 17, 'attribute set';
    $obj->attr(18);
    is $obj->attr, 18, 'attribute changed';
};

do {
    package TestChild;
    use MooseX::Glib;
    extends 'TestBase';
    has attr2 => (is => 'rw');
    reify;
};

do {
    my $obj = TestChild->new(attr => 17, attr2 => 40);
    is $obj->foo, 23, 'signal on child';
    is $obj->attr, 17, 'parent attribute set';
    is $obj->attr2, 40, 'child attribute set';
    $obj->attr(18);
    is $obj->attr, 18, 'parent attribute changed';
};

do {
    package TestFailures;
    use MooseX::Glib;
    ::like(
        ::exception { extends qw( TestBase TestChild ) },
        qr{multiple\s+inheritance}i,
        'cannot extend more than one class',
    );
};

done_testing;
