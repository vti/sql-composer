package SQL::Builder::Insert;

use strict;
use warnings;

require Carp;
use SQL::Builder::Quoter;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{quoter} = $params{quoter} || SQL::Builder::Quoter->new;

    my $sql = '';
    my @bind;

    $sql .= 'INSERT INTO ';

    $sql .= $self->_quote($params{into});

    if ($params{values}) {
        my @columns;
        while (my ($key, $value) = splice @{$params{values}}, 0, 2) {
            push @columns, $key;
            push @bind,    $value;
        }
        $sql .= ' (' . (join ',', map { $self->_quote($_) } @columns) . ')';
        $sql .= ' VALUES (';
        $sql .= join ',', split //, '?' x @columns;
        $sql .= ')';
    }

    $self->{sql}  = $sql;
    $self->{bind} = \@bind;

    return $self;
}

sub to_sql { shift->{sql} }
sub to_bind { @{shift->{bind} || []} }

sub _quote {
    my $self = shift;
    my ($column, $prefix) = @_;

    return $self->{quoter}->quote($column, $prefix);
}

1;
