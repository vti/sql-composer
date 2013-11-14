package SQL::Builder::Select;

use strict;
use warnings;

require Carp;
use SQL::Builder::Join;
use SQL::Builder::Expression;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{from}    = $params{from};
    $self->{columns} = $params{columns};

    $self->{join} = $params{join};
    $self->{join} = [$self->{join}]
      if $self->{join} && ref $self->{join} ne 'ARRAY';

    $self->{quoter} = $params{quoter} || SQL::Builder::Quoter->new;

    my @columns =
      map { $self->_prepare_column($_, $self->{from}) } @{$self->{columns}};
    push @columns, $self->_collect_columns_from_joins($self->{join});

    my $sql = '';
    my @bind;

    $sql .= 'SELECT ';

    if (@columns) {
        $sql .= join ',', @columns;
    }

    $sql .= ' FROM ';
    $sql .= $self->_quote($params{from});

    if (my $joins = $self->{join}) {
        my ($join_sql, $join_bind) = $self->_build_join($joins);
        $sql .= $join_sql;
        push @bind, @$join_bind;
    }

    if ($params{where}) {
        my $expr = SQL::Builder::Expression->new(
            default_prefix => $self->{from},
            quoter         => $self->{quoter},
            expr           => $params{where}
        );
        $sql .= ' WHERE ' . $expr->to_sql;
        push @bind, $expr->to_bind;
    }

    if (my $order_by = $params{order_by}) {
        $sql .= ' ORDER BY ';
        if (ref $order_by) {
            if (ref($order_by) eq 'ARRAY') {
                my @order;
                while (my ($key, $value) = splice @$order_by, 0, 2) {
                    push @order, $self->_quote($key) . ' ' . uc($value);
                }
                $sql .= join ',', @order;
            }
            else {
                Carp::croak('unexpected reference');
            }
        }
        else {
            $sql .= $self->_quote($order_by);
        }
    }

    if (my $limit = $params{limit}) {
        $sql .= ' LIMIT ' . $limit;
    }

    if (my $offset = $params{offset}) {
        $sql .= ' OFFSET ' . $offset;
    }

    $self->{sql}  = $sql;
    $self->{bind} = \@bind;

    return $self;
}

sub to_sql { shift->{sql} }
sub to_bind { @{shift->{bind} || []} }

sub from_rows {
    my $self = shift;
    my ($rows) = @_;

    my $result = [];
    foreach my $row (@$rows) {
        my $set = {};

        $self->_populate($set, $row, $self->{columns});

        $self->_populate_joins($set, $row, $self->{join});

        push @$result, $set;
    }

    return $result;
}

sub _prepare_column {
    my $self = shift;
    my ($column, $prefix) = @_;

    if (ref $column eq 'SCALAR') {
        return $$column;
    }
    elsif (ref $column eq 'HASH') {
        return (
            ref($column->{-col})
            ? ${$column->{-col}}
            : $self->_quote($column->{-col}, $prefix)
          )
          . ' AS '
          . $self->_quote($column->{-as});
    }
    else {
        return $self->_quote($column, $prefix);
    }
}

sub _populate {
    my $self = shift;
    my ($set, $row, $columns) = @_;

    my $name;
    foreach my $column (@$columns) {
        if (ref($column) eq 'HASH') {
            $name = $column->{-as};
        }
        elsif (ref($column) eq 'SCALAR') {
            $name = $$column;
        }
        else {
            $name = $column;
        }

        $set->{$name} = shift @$row;
    }
}

sub _populate_joins {
    my $self = shift;
    my ($set, $row, $joins) = @_;

    foreach my $join (@$joins) {
        $set->{$join->{source}} ||= {};
        $self->_populate($set->{$join->{source}}, $row, $join->{columns});

        if (my $subjoin = $join->{join}) {
            $set->{$join->{source}}->{$subjoin->{source}} ||= {};
            $self->_populate($set->{$join->{source}}->{$subjoin->{source}},
                $row, $subjoin->{columns});
        }
    }
}

sub _collect_columns_from_joins {
    my $self = shift;
    my ($joins) = @_;

    return () unless $joins && @$joins;

    my @join_columns;
    foreach my $join_params (@$joins) {
        if (my $join_columns = $join_params->{columns}) {
            push @join_columns, map {
                $self->_prepare_column($_,
                      $join_params->{as}
                    ? $join_params->{as}
                    : $join_params->{source})
            } @$join_columns;
        }

        if (my $subjoins = $join_params->{join}) {
            $subjoins = [$subjoins] unless ref $subjoins eq 'ARRAY';

            push @join_columns, $self->_collect_columns_from_joins($subjoins);
        }
    }

    return @join_columns;
}

sub _build_join {
    my $self = shift;
    my ($joins) = @_;

    $joins = [$joins] unless ref $joins eq 'ARRAY';

    my $sql = '';
    my @bind;
    foreach my $join_params (@$joins) {
        my $join =
          SQL::Builder::Join->new(quoter => $self->{quoter}, %$join_params);

        $sql .= ' ' . $join->to_sql;
        push @bind, $join->to_bind;

        if (my $subjoin = $join_params->{join}) {
            my ($subsql, $subbind) = $self->_build_join($subjoin);
            $sql .= $subsql;
            push @bind, @$subbind;
        }
    }

    return ($sql, \@bind);
}

sub _quote {
    my $self = shift;
    my ($column, $prefix) = @_;

    return $self->{quoter}->quote($column, $prefix);
}

1;
