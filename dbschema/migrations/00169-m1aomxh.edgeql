CREATE MIGRATION m1aomxhi7zqwviopshdtbrkeeuscr4623vemyrh2226rpvaikaqwlq
    ONTO m1h3ndjms2cvq3zc4siaw67wzchhrt4qmtf4kjbvl35c3kqftbqrsq
{
  CREATE SCALAR TYPE default::Client EXTENDING enum<Python>;
  ALTER TYPE default::FileImport {
      CREATE PROPERTY client: default::Client;
  };
  ALTER TYPE default::FileImport {
      CREATE PROPERTY client_version: std::str;
      DROP PROPERTY importer;
  };
  ALTER TYPE default::TestStepRun {
      CREATE LINK action := (.<steps[IS default::Action]);
  };
};
