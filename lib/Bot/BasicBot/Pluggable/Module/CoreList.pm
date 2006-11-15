package Bot::BasicBot::Pluggable::Module::CoreList;

use strict;
use Bot::BasicBot::Pluggable::Module;
use Module::CoreList;

use vars qw( @ISA $VERSION );
@ISA     = qw(Bot::BasicBot::Pluggable::Module);
$VERSION = '0.02';

my $ident = qr/[A-Za-z_][A-Za-z_0-9]*/;

sub told {
    my ( $self, $mess ) = @_;
    my $bot = $self->bot();

    # we must be directly addressed
    return
        if !( ( defined $mess->{address} && $mess->{address} eq $bot->nick() )
        || $mess->{channel} eq 'msg' );

    # ignore people we ignore
    return if $bot->ignore_nick( $mess->{who} );

    # only answer to our command (which can be our name too)
    my $src = $bot->nick() eq 'corelist' ? 'raw_body' : 'body';
    return if $mess->{$src} !~ /^\s*corelist.*?($ident(?:::$ident)*)/i;

    # grab the parameter list
    my $module = $1;

    # compute the reply
    my ( $release, $patchlevel, $date )
        = ( Module::CoreList->first_release($module), '', '' );
    if ($release) {
        $patchlevel = $release && %Module::CoreList::patchlevel
            ? join( "/", @{ $Module::CoreList::patchlevel{$release} } )
            : '';
        $date = $Module::CoreList::released{$release};
    }

    return $release
        ? "$module was first released with perl $release "
        . ( $patchlevel ? "(patchlevel $patchlevel, " : '' )
        . "released on $date)"
        : "$module is not in the core";
}

sub help {'corelist module'}

1;

__END__

=head1 NAME

Bot::BasicBot::Pluggable::Module::CoreList - IRC frontend to Module::CoreList

=head1 SYNOPSIS

    < you> bot: corelist File::Spec
    < bot> File::Spec was first released with perl 5.00503 (released on 1999-03-28)

=head1 DESCRIPTION

This module is a frontend to the excellent C<Module::CoreList> module
which will let you know what modules shipped with which versions of perl,
over IRC.

=head1 IRC USAGE

To learn about the presence or absence of a module in the Perl core,
simply ask:

    corelist Test::More

to which the bot will reply:

    Test::More was first released with perl 5.7.3 (patchlevel perl/15039, released on 2002-03-05)  

=head1 AUTHOR

Philippe "BooK" Bruhat, C<< <book@cpan.org> >>, inspired by the existing
C<corelist> bot, last seen on IRC in May 2006.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-bot-basicbot-pluggable-module-corelist@rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/>. I will be notified, and
then you'll automatically be notified of progress on your bug as I
make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2006 Philippe "BooK" Bruhat, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
