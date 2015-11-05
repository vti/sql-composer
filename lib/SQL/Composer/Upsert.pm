package SQL::Composer::Upsert;

use strict;
use warnings;

use SQL::Composer::Insert;

our @ISA; BEGIN { @ISA = ('SQL::Composer::Insert') };

sub new {
    my $class = shift;
    my (%params) = @_;

    my $driver = $params{driver}
        || die 'Cannot create an Upsert object without specifying a `driver`';

    my $upsert = '';
    if ($driver =~ m/sqlite/i) {
        $upsert = ' ON CONFLICT REPLACE'
    }
    elsif ($driver =~ m/mysql/i) {
        $upsert = ' ON DUPLICATE KEY UPDATE'
    }
    elsif ($driver =~ m/pg/i) {
        $upsert = ' ON CONFLICT DO UPDATE'
    }
    else {
        die 'The Upsert `driver` (' . $driver . ') is not supported';
    }

    my $self = $class->SUPER::new( %params );
    $self->{sql} .= $upsert;

    return $self;
}

1;
__END__

=pod

=head1

SQL::Composer::Upsert - UPSERT statement emulation

=head1 SYNOPSIS

    my $upsert = SQL::Composer::Upsert->new(
        into   => 'table',
        values => [ id => 1, foo => 'bar' ],
        driver => $driver # driver must be set
    );

    my $sql = $upsert->to_sql;
    # SQLite: 'INSERT INTO `table` (`id`, `foo`) VALUES (?, ?) ON CONFLICT UPDATE'
    # MySQL: 'INSERT INTO `table` (`id`, `foo`) VALUES (?, ?) ON DUPLICATE KEY UPDATE'
    # Pg: 'INSERT INTO `table` (`id`, `foo`) VALUES (?, ?) ON CONFLICT DO UPDATE'
    my @bind = $upsert->to_bind; # [1, 'bar']

=head1 DESCRIPTION

This emulates the C<UPSERT> statement, which is defined as an attempt to
C<INSERT> failing due to a key constraint and the query being turned into
an C<UPDATE> instead.

=head1 CAVEAT

Since this feature is not universally supported, you must specify a C<driver>
when creating C<SQL::Composer::Upsert> instance so that we can generate the
correct SQL.

It should also be noted that we support the lowest common denominator, which
is the basic C<UPSERT> behavior even though some RDBMS support more complex
features.

=cut
