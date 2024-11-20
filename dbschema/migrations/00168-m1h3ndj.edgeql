CREATE MIGRATION m1h3ndjms2cvq3zc4siaw67wzchhrt4qmtf4kjbvl35c3kqftbqrsq
    ONTO m1pz6ultt3byificwf3uvgjmbe2gyiayfsynwamafcikrotpppybja
{
  ALTER TYPE default::Action {
      ALTER LINK fileImport {
          ON SOURCE DELETE ALLOW;
          ON TARGET DELETE ALLOW;
      };
  };
  ALTER TYPE default::FileImport {
      CREATE PROPERTY input: std::json;
      CREATE MULTI PROPERTY warnings: std::str;
  };
};
