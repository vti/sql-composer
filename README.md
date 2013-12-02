# NAME

SQL::Builder - sql builder

# SYNOPSIS

    use DBI;

    my $select = SQL::Builder->build('select',
        from    => 'book_description',
        columns => ['description'],
        join    => [
            {
                source  => 'book',
                columns => ['title'],
                on      => ['book_description.book_id' => {-col => 'book.id'}],
                join    => [
                    {
                        source  => 'author',
                        columns => ['name'],
                        on      => ['book.author_id' => {-col => 'author.id'}]
                    }
                ]
            }
        ]
    );

    my $sql  = $select->to_sql;
    my @bind = $select->to_bind;

    my $dbh = DBI->connect(...);
    my $sth = dbh->prepare($sql);
    $sth->execute(@bind);
    my $rows = $sth->fetchall_arrayref;

    my $objects = $select->from_rows($rows);

    # $objects = [
    #   description => 'Nice Book',
    #   book => {
    #       title => 'My Book',
    #       author => {
    #           name => 'Author'
    #       }
    #   }
    # ]

# DESCRIPTION

[SQL::Builder](http://search.cpan.org/perldoc?SQL::Builder) is a SQL builder and rows parser in one module. It behaves very
close to [SQL::Abstract](http://search.cpan.org/perldoc?SQL::Abstract) or similar modules but allows deep joins and automatic
convertion from arrayref to a hashref, keeping the nested join structure if
needed.

This module itself is just a factory for the common SQL statements: `SELECT`,
`DELETE`, `INSERT` and `UPDATE`.

# METHODS

## `build`

Build SQL statement.

    my $select = SQL::Builder->build('select, @params);

# SQL

## SQL expressions

SQL expressions are everything used in `where`, `join` and other statements.
So the following rules apply to all of them. For more details see
[SQL::Builder::Expression](http://search.cpan.org/perldoc?SQL::Builder::Expression).

    my $expr = SQL::Builder::Expression->new(expr => [a => 'b']);

    my $sql = $expr->to_sql;   # `a` = ?
    my @bind = $expr->to_bind; # ('b')

## SQL Joins

For more details see [SQL::Builder::Join](http://search.cpan.org/perldoc?SQL::Builder::Join).

    my $expr = SQL::Builder::Join->new(source => 'table', on => [a => 'b']);

    my $sql = $expr->to_sql;   # JOIN `table` ON `table`.`a` = ?
    my @bind = $expr->to_bind; # ('b')

## SQL Inserts

For more details see [SQL::Builder::Select](http://search.cpan.org/perldoc?SQL::Builder::Select).

    my $expr =
      SQL::Builder::Insert->new(into => 'table', values => [foo => 'bar']);

    my $sql = $expr->to_sql;   # INSERT INTO `table` (`foo`) VALUES (?)
    my @bind = $expr->to_bind; # ('bar')

## SQL Updates

For more details see [SQL::Builder::Update](http://search.cpan.org/perldoc?SQL::Builder::Update).

    my $expr =
      SQL::Builder::Update->new(table => 'table', values => [a => 'b']);

    my $sql = $expr->to_sql;   # UPDATE `table` SET `a` = ?
    my @bind = $expr->to_bind; # ('b')

## SQL Deletes

For more details see [SQL::Builder::Delete](http://search.cpan.org/perldoc?SQL::Builder::Delete).

    my $expr = SQL::Builder::Delete->new(from => 'table');

    my $sql = $expr->to_sql;   # DELETE FROM `table`
    my @bind = $expr->to_bind; # ()

## SQL Selects

For more details see [SQL::Builder::Select](http://search.cpan.org/perldoc?SQL::Builder::Select).

    my $expr =
      SQL::Builder::Select->new(from => 'table', columns => ['a', 'b']);

    my $sql = $expr->to_sql;   # SELECT `table`.`a`,`table`.`b` FROM `table`
    my @bind = $expr->to_bind; # ()

    my $objects = $expr->from_rows([['c', 'd']]); # [{a => 'c', b => 'd'}];

# AUTHOR

Viacheslav Tykhanovskyi

# COPYRIGHT AND LICENSE

Copyright 2013, Viacheslav Tykhanovskyi.

This module is free software, you may distribute it under the same terms as Perl.
