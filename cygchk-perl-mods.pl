#!/usr/bin/perl
# Last modified: Tue Mar 24 11:57:45 2026

use strict;
use v5.18;
use utf8;
use warnings;
use Carp qw/ carp croak /;
=head1 NAME
cygchk-perlmods.pl

=head1 SYNOPSIS
cygchk-perlmods.pl "IO-*"      # "glob expression"

=head1 VERSION
0.10

=head1 AUTHOR
Soren Andersen C<somian08@gmail.com>

=cut

if ( @ARGV * 1 == 0 ) {
    croak 'You must type an argument. Exiting.';
}
my ($globexpr) = @ARGV;
my $as_perl_says;

if ($globexpr !~/^perl-/) {  # you may omit the "perl-" prefix in the argument
    $globexpr = 'perl-' . $globexpr;
}

$globexpr = lc $globexpr;
open( my $ok_fh, '-|', "cygcheck", "-e", $globexpr);
croak "Dying from no open on cygcheck" unless $ok_fh;

printf( "Matching distributions packaged for Cygwin:\n" );
my ( @dists, $mlen );
$mlen = 0;
while (<$ok_fh>) {
     my $setup_name = $_;
     my $nonly = (split( ' : ' ))[0];
     $mlen = length($nonly) > $mlen ? length($nonly) : $mlen;
     push @dists, $nonly;
}
for (@dists) {
     my $e = substr($_,5);
     $e =~s/-/::/g;
     $as_perl_says = $e;
     my $report_str = sprintf( "%-${mlen}s  %s" =>
                              $_, $as_perl_says );
     $report_str .=  q[ ].chk_inst( $as_perl_says );
     say $report_str;
}

sub chk_inst {
    local $::pkgname = $_[0];
    eval qq{require $::pkgname;};
    unless ( $@ ) {
        my $pm = $_[0];
        $pm =~ s{::}{/}g;
        $pm .= '.pm';
        return 'is installed as '. $INC{ $pm };
    } else {
        return 'is not installed';
    }
}
__END__

=head1 LICENSE
This program is Free software, made available under the same terms as Perl.
THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

=cut

# vim: ft=perl et sw=4 ts=4 :
