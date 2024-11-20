CREATE MIGRATION m1w2nfu7v7e3zhfud2pu6biypqrbth7w3r6uupkn7vykq6x6qri4da
    ONTO m16u3vjz3iudrc5p6h454i4fe2znv5wetfdzjox6aolodxalnb2fba
{
  CREATE GLOBAL default::apiKey -> std::uuid;
  ALTER TYPE default::User {
      CREATE PROPERTY apiKey: std::uuid {
          CREATE CONSTRAINT std::exclusive;
      };
  };
  CREATE GLOBAL default::apiUser := (SELECT
      default::User
  FILTER
      (.apiKey = GLOBAL default::apiKey)
  );
  ALTER TYPE default::PrimitiveProperty {
      CREATE ACCESS POLICY IAllowAPIUserToSelect
          ALLOW SELECT USING ((((GLOBAL default::apiUser).organization ?= .organization) ?? false));
  };
  ALTER TYPE default::Primitive {
      CREATE ACCESS POLICY IAllowAPIUserToSelectAndInsert
          ALLOW SELECT, INSERT USING ((((GLOBAL default::apiUser).organization ?= .organization) ?? false));
  };
};
