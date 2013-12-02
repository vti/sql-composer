package SQL::Builder::Delete;

use strict;
use warnings;

require Carp;
use SQL::Builder::Quoter;
use SQL::Builder::Expression;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{quoter} = $params{quoter} || SQL::Builder::Quoter->new;

    my $sql = '';
    my @bind;

    $sql .= 'DELETE FROM ';

    $sql .= $self->_quote($params{from});

    if ($params{where}) {
        my $expr = SQL::Builder::Expression->new(
            quoter => $self->{quoter},
            expr   => $params{where}
        );
        $sql .= ' WHERE ' . $expr->to_sql;
        push @bind, $expr->to_bind;
    }

    $self->{sql}  = $sql;
    $self->{bind} = \@bind;

    return $self;
}

sub to_sql { shift->{sql} }
sub to_bind { @{shift->{bind} || []} }

sub _quote {
    my $self = shift;
    my ($column) = @_;

    return $self->{quoter}->quote($column);
}

1;
__END__

=pod

=head1

SQL::Builder::Delete - DELETE statement

=head1 SYNOPSIS

    my $delete = SQL::Builder::Delete->new(from => 'table', where => [a => 'b']);

    my $sql = $delete->to_sql;   # 'DELETE FROM `table` WHERE `a` = ?'
    my @bind = $delete->to_bind; # ['b']

=cut
