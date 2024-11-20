CREATE MIGRATION m1rlytv6ojtl4jbltnhbuiauvb3krcec4subuuod33n5gdnebmcjlq
    ONTO m147bj23xegdszbuybllz7xwdbp7pumdr2auvmagf7y4n2khhrbvma
{
  CREATE TYPE default::FileImport EXTENDING default::PrimitiveProperty {
      ALTER LINK organization {
          SET default := ((GLOBAL default::userCurrent).organization);
          SET OWNED;
          SET readonly := true;
          SET TYPE default::Organization;
      };
      CREATE ACCESS POLICY IAllowSuperAdminToSelectForAnalytics
          ALLOW SELECT USING (((GLOBAL default::userCurrent).superAdmin ?? false));
      CREATE REQUIRED LINK upload: default::Upload;
      CREATE PROPERTY error: std::str;
      CREATE PROPERTY importer: std::str;
      CREATE REQUIRED PROPERTY status: default::StatusCategory {
          SET default := (default::StatusCategory.Pending);
      };
  };
  ALTER TYPE default::Action {
      CREATE LINK fileImport: default::FileImport;
  };
  ALTER TYPE default::FileImport {
      CREATE MULTI LINK runs := (.<fileImport[IS default::Action]);
  };
  CREATE TYPE default::TestStepRun EXTENDING default::PrimitiveProperty {
      ALTER LINK organization {
          SET default := ((GLOBAL default::userCurrent).organization);
          SET OWNED;
          SET readonly := true;
          SET TYPE default::Organization;
      };
      CREATE ACCESS POLICY IAllowSuperAdminToSelectForAnalytics
          ALLOW SELECT USING (((GLOBAL default::userCurrent).superAdmin ?? false));
      CREATE LINK parent: default::TestStepRun;
      CREATE MULTI LINK children := (.<parent[IS default::TestStepRun]);
      CREATE PROPERTY endedAt: std::datetime;
      CREATE PROPERTY passed: std::bool;
      CREATE PROPERTY startedAt: std::datetime;
      CREATE PROPERTY value: std::int64;
  };
  ALTER TYPE default::Action {
      CREATE MULTI LINK steps: default::TestStepRun {
          ON TARGET DELETE ALLOW;
      };
  };
  CREATE TYPE default::TestStep EXTENDING default::PrimitiveProperty {
      ALTER LINK organization {
          SET default := ((GLOBAL default::userCurrent).organization);
          SET OWNED;
          SET readonly := true;
          SET TYPE default::Organization;
      };
      CREATE ACCESS POLICY IAllowSuperAdminToSelectForAnalytics
          ALLOW SELECT USING (((GLOBAL default::userCurrent).superAdmin ?? false));
      CREATE LINK parent: default::TestStep;
      CREATE MULTI LINK children := (.<parent[IS default::TestStep]);
      CREATE PROPERTY highLimit: std::int64;
      CREATE PROPERTY lowLimit: std::int64;
      CREATE PROPERTY measurement: std::str;
      CREATE PROPERTY name: std::str;
      CREATE PROPERTY units: std::str;
  };
  ALTER TYPE default::Procedure {
      CREATE MULTI LINK steps: default::TestStep {
          ON TARGET DELETE ALLOW;
      };
  };
  ALTER TYPE default::TestStepRun {
      CREATE REQUIRED LINK template: default::TestStep {
          ON TARGET DELETE ALLOW;
      };
  };
  ALTER TYPE default::TestStep {
      CREATE MULTI LINK instances := (.<template[IS default::TestStepRun]);
  };
};
