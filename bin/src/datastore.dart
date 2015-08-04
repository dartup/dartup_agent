part of dartup_agent;

typedef Stream<Site> GetSites();

/// Loads Site data from an Postgres Database.
///
/// It looks for connection parameters in an environmental variable called
/// POSTGRES_URI. Then the main site information is in the site table.
///
/// Will get all the sites that are not evil.
Stream<Site> postgresGetSites() async* {
  var con = await connect(Platform.environment['POSTGRES_URI']);
  var result = await con
  .query('SELECT name,giturl,envvar FROM site where evil = false;');
  yield* result.map((Row r) => new Site(r.name, r.giturl, r.envvar));
}