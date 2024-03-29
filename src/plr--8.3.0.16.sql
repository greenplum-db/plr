CREATE FUNCTION plr_call_handler()
RETURNS LANGUAGE_HANDLER
AS 'MODULE_PATHNAME' LANGUAGE C;

CREATE LANGUAGE plr HANDLER plr_call_handler;

CREATE OR REPLACE FUNCTION plr_version ()
RETURNS text
AS 'MODULE_PATHNAME','plr_version'
LANGUAGE C;

CREATE OR REPLACE FUNCTION reload_plr_modules ()
RETURNS text
AS 'MODULE_PATHNAME','reload_plr_modules'
LANGUAGE C;

CREATE OR REPLACE FUNCTION install_rcmd (text)
RETURNS text
AS 'MODULE_PATHNAME','install_rcmd'
LANGUAGE C STRICT;
REVOKE EXECUTE ON FUNCTION install_rcmd (text) FROM PUBLIC;

CREATE OR REPLACE FUNCTION plr_singleton_array (float8)
RETURNS float8[]
AS 'MODULE_PATHNAME','plr_array'
LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION plr_array_push (_float8, float8)
RETURNS float8[]
AS 'MODULE_PATHNAME','plr_array_push'
LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION plr_array_accum (_float8, float8)
RETURNS float8[]
AS 'MODULE_PATHNAME','plr_array_accum'
LANGUAGE C;

CREATE TYPE plr_environ_type AS (name text, value text);
CREATE OR REPLACE FUNCTION plr_environ ()
RETURNS SETOF plr_environ_type
AS 'MODULE_PATHNAME','plr_environ'
LANGUAGE C;

REVOKE EXECUTE ON FUNCTION plr_environ() FROM PUBLIC;

CREATE TYPE r_typename AS (typename text, typeoid oid);
CREATE OR REPLACE FUNCTION r_typenames()
RETURNS SETOF r_typename AS '
  x <- ls(name = .GlobalEnv, pat = "OID")
  y <- vector()
  for (i in 1:length(x)) {y[i] <- eval(parse(text = x[i]))}
  data.frame(typename = x, typeoid = y)
' language 'plr';

CREATE OR REPLACE FUNCTION load_r_typenames()
RETURNS text AS '
  sql <- "select upper(typname::text) || ''OID'' as typename, oid from pg_catalog.pg_type where typtype = ''b'' order by typname"
  rs <- pg.spi.exec(sql)
  for(i in 1:nrow(rs))
  {
    typobj <- rs[i,1]
    typval <- rs[i,2]
    if (substr(typobj,1,1) == "_")
      typobj <- paste("ARRAYOF", substr(typobj,2,nchar(typobj)), sep="")
    assign(typobj, typval, .GlobalEnv)
  }
  return("OK")
' language 'plr';

CREATE TYPE r_version_type AS (name text, value text);
CREATE OR REPLACE FUNCTION r_version()
RETURNS setof r_version_type as '
  cbind(names(version),unlist(version))
' language 'plr';

CREATE OR REPLACE FUNCTION plr_set_rhome (text)
RETURNS text
AS 'MODULE_PATHNAME','plr_set_rhome'
LANGUAGE C STRICT;
REVOKE EXECUTE ON FUNCTION plr_set_rhome (text) FROM PUBLIC;

CREATE OR REPLACE FUNCTION plr_unset_rhome ()
RETURNS text
AS 'MODULE_PATHNAME','plr_unset_rhome'
LANGUAGE C;
REVOKE EXECUTE ON FUNCTION plr_unset_rhome () FROM PUBLIC;

CREATE OR REPLACE FUNCTION plr_set_display (text)
RETURNS text
AS 'MODULE_PATHNAME','plr_set_display'
LANGUAGE C STRICT;
REVOKE EXECUTE ON FUNCTION plr_set_display (text) FROM PUBLIC;

CREATE OR REPLACE FUNCTION plr_get_raw (bytea)
RETURNS bytea
AS 'MODULE_PATHNAME','plr_get_raw'
LANGUAGE C STRICT;

