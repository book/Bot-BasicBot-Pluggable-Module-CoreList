use Test::More;
use Bot::BasicBot::Pluggable::Module::CoreList;
use strict;

my $nick;

# create a mock bot
{
    no warnings;

    package Bot::BasicBot::Pluggable::Module;
    sub bot { bless {}, 'Bot::BasicBot' }

    package Bot::BasicBot;
    sub ignore_nick { $_[1] eq 'ignore_me' }
    sub nick {$nick}
}

my $datadumper = $Module::CoreList::VERSION >= 2.01
    ? 'Data::Dumper was first released with perl 5.005 (patchlevel perl/1647, released on 1998-07-22)'
    : 'Data::Dumper was first released with perl 5.005 (released on 1998-07-22)';

diag "Testing with Module::CoreList version $Module::CoreList::VERSION";

# test the told() method
my @tests = (
    [   {   'body'     => 'hello bam',
            'raw_nick' => 'BooK!~book@d83-179-185-40.cust.tele2.fr',
            'who'      => 'BooK',
            'channel'  => '#zlonkbam',
            'raw_body' => 'hello bam',
            '_nick'    => 'bam',
        } => undef
    ],
    [   {   'body'     => 'welcome here',
            'raw_nick' => 'BooK!~book@d83-179-185-40.cust.tele2.fr',
            'who'      => 'BooK',
            'address'  => 'bam',
            'channel'  => '#zlonkbam',
            'raw_body' => 'bam: welcome here',
            '_nick'    => 'bam',
        } => undef
    ],
    [   {   'body'     => 'hi bam',
            'raw_nick' => 'BooK!~book@d83-179-185-40.cust.tele2.fr',
            'who'      => 'BooK',
            'address'  => 'msg',
            'channel'  => 'msg',
            'raw_body' => 'hi bam',
            '_nick'    => 'bam',
        } => undef
    ],
    [   {   'body'     => 'corelist bam blonk zlonk',
            'raw_nick' => 'BooK!~book@d83-179-185-40.cust.tele2.fr',
            'who'      => 'BooK',
            'channel'  => '#zlonkbam',
            'raw_body' => 'corelist bam blonk zlonk ',
            '_nick'    => 'bam',
        } => undef
    ],
    [   {   'body'     => 'corelist Data::Dumper',
            'raw_nick' => 'BooK!~book@d83-179-185-40.cust.tele2.fr',
            'who'      => 'BooK',
            'address'  => 'msg',
            'channel'  => 'msg',
            'raw_body' => 'corelist Data::Dumper ',
            '_nick'    => 'bam',
        } => $datadumper,
    ],
    [   {   'body'     => 'corelist:Data::Dumper',
            'raw_nick' => 'BooK!~book@d83-179-185-40.cust.tele2.fr',
            'who'      => 'BooK',
            'address'  => 'msg',
            'channel'  => 'msg',
            'raw_body' => 'corelist:Data::Dumper',
            '_nick'    => 'bam',
        } => $datadumper,
    ],
    [   {   'body'     => 'corelist:Bam::Blonk::Zlonk',
            'raw_nick' => 'BooK!~book@d83-179-185-40.cust.tele2.fr',
            'who'      => 'ignore_me',                  # will be ignored
            'address'  => 'msg',
            'channel'  => 'msg',
            'raw_body' => 'corelist:Bam::Blonk::Zlonk',
            '_nick'    => 'bam',
        } => undef,
    ],
    [   {   'body'     => 'Bam::Blonk::Zlonk',
            'raw_nick' => 'BooK!~book@d83-179-185-40.cust.tele2.fr',
            'who'      => 'BooK',
            'address'  => 'corelist',
            'channel'  => '#zlonkbam',
            'raw_body' => 'corelist Bam::Blonk::Zlonk',
            '_nick'    => 'corelist',
        } => 'Bam::Blonk::Zlonk is not in the core',
    ],
    [   {   'body'     => 'zlonk',
            'raw_nick' => 'BooK!~book@d83-179-185-40.cust.tele2.fr',
            'who'      => 'BooK',
            'address'  => 'corelist',
            'channel'  => '#zlonkbam',
            'raw_body' => 'corelist zlonk',
            '_nick'    => 'corelist',
        } => 'zlonk is not in the core',
    ],
    [   {   'body'     => 'corelist zlonk',
            'raw_nick' => 'BooK!~book@d83-179-185-40.cust.tele2.fr',
            'who'      => 'BooK',
            'address'  => 'bam',
            'channel'  => '#zlonkbam',
            'raw_body' => 'bam: corelist zlonk',
            '_nick'    => 'bam',
        } => 'zlonk is not in the core',
    ],
);

plan tests => @tests + 1;

my $pkg = 'Bot::BasicBot::Pluggable::Module::CoreList';

# quick test of the help string
like( $pkg->help(), qr/corelist module/, 'Basic usage line' );

for my $t (@tests) {
    $nick = delete $t->[0]{_nick};    # setup our nick
    is( $pkg->told( $t->[0] ),
        $t->[1],
        qq{Answer to "$t->[0]{raw_body}" on channel $t->[0]{channel}} );
}

