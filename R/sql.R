#' Create an index
#' 
#' Create and index on an existing table column
#' 
#' @param tablename the name of the table
#' @param columnname the name of the column
#' @param schemaname specifically in this schema
#' @param indexname optional index name to use
#' @param unique if true, create a unique index
#' @param using the index method
#' @param collate set collation
#' @param descending if true, sort descending
#' @param tablespace create in this tablespace
#' @param where restrict to rows matching predicate
#' 
#' @details Build an index on a column.
#' 
#' @author Timothy H. Keitt
#' 
#' @export
#' @aliases sql
#' @rdname sql
create_index = function(tablename,
                        columnname,
                        schemaname = NULL,
                        indexname = NULL,
                        unique = FALSE,
                        using = NULL,
                        collate = NULL,
                        descending = FALSE,
                        tablespace = NULL,
                        where = NULL){
  sp = savepoint(); on.exit(rollback(sp))
  tableschema = format_tablename(tablename, schemaname)
  prefix = if (unique) "CREATE UNIQUE INDEX" else "CREATE INDEX"
  if (!is.null(indexname)) prefix = paste(prefix, indexname)
  if (!is.null(using)) tableschema = paste(tableschema, "USING", using)
  sql = paste(prefix, "ON", tableschema, "(", dquote_esc(columnname), ")")
  if (!is.null(collate)) sql = paste(sql, "COLLATE", collate)
  if (descending) sql = paste(sql, "DESC")
  if (!is.null(tablespace)) sql = paste(sql, "TABLESPACE", tablespace)
  if (!is.null(where)) sql = paste(sql, "WHERE", where)
  execute(sql); on.exit(commit(sp))}

#' @export
#' @rdname sql
add_primary_key = function(tablename,
                           columnname,
                           schemaname = NULL){
  sp = savepoint(); on.exit(rollback(sp))
  tableschema = format_tablename(tablename, schemaname)
  execute("ALTER TABLE", tableschema, "ADD PRIMARY KEY (", columnname, ")")
  on.exit(commit(sp))}

#' @param foreign_table the foreign table name
#' @param foreign_column a key column (defaults to primary key)
#' @param foreign_schema the schema of the foreign table
#' @export
#' @rdname sql
add_foreign_key = function(tablename,
                           columnname,
                           foreign_table,
                           foreign_column = NULL,
                           schemaname = NULL,
                           foreign_schema = schemaname){
  sp = savepoint(); on.exit(rollback(sp))
  tableschema = format_tablename(tablename, schemaname)
  foreign_tableschema = format_tablename(foreign_table, foreign_schema)
  execute("ALTER TABLE", tableschema,
          "ADD FOREIGN KEY (", columnname, ")",
          "REFERENCES", foreign_tableschema,
          ifelse(is.null(foreign_column), "",
                 paste("(", foreign_column, ")")))
  on.exit(commit(sp))}

#' @export
#' @rdname sql
create_schema = function(schemaname){
  execute("CREATE SCHEMA", schemaname)}

#' PostgreSQL path variable
#' 
#' Manipulate the PostgreSQL path variable
#' 
#' @param ... path names
#' @param default if true, manipulate database default
#' @param no_dup do not add if path exists
#' 
#' @export
#' @rdname path
set_path = function(..., default = FALSE)
{
  sp = savepoint()
  on.exit(rollback(sp))
  if (default)
    execute("ALTER DATABASE", get_conn_info("dbname"),
            "SET search_path TO", paste(..., sep = ", ")) else
    execute("SET search_path TO", paste(..., sep = ", "))
  on.exit(commit(sp))
}

#' @export
#' @rdname path
get_path = function(default = FALSE)
  if (default)
  {
    path = get_path()
    on.exit(set_path(path))
    set_path("default")
    return(get_path())
   } else
     fetch("show search_path")[[1]]

#' @export
#' @rdname path
append_path = function(..., default = FALSE, no_dup = TRUE)
  if (no_dup && any(path_contains(..., default = default)))
    warning("Path not updated") else
      set_path(get_path(default = default), ..., default = default)

#' @export
#' @rdname path
prepend_path = function(..., default = FALSE, no_dup = TRUE)
  if (no_dup && any(path_contains(..., default = default)))
    warning("Path not updated") else
      set_path(..., get_path(default = default), default = default)

#' @export
#' @rdname path
path_contains = function(..., default = FALSE)
  sapply(list(...), grepl, x = strsplit(get_path(default = default), ", ", fixed = TRUE))

#' @param columntype the column SQL type
#' @rdname sql
#' @export
add_column = function(columnname, columntype, tablename, schemaname = NULL)
{
  sp = savepoint()
  on.exit(rollback(sp))
  tableschema = format_tablename(tablename, schemaname)
  status = execute("ALTER TABLE", tableschema, "ADD COLUMN", columnname, columntype)
  on.exit(commit(sp))
  return(status)
}

#' @param name name of the database
#' @rdname sql
#' @export
createdb = function(name)
{
  execute("CREATE DATABASE", name)
}

#' @param if_exists don't fail on missing database
#' @rdname sql
#' @export
dropdb = function(name, if_exists = TRUE)
{
  execute("DROP DATABASE", if (if_exists) "IF EXISTS", name)
}


