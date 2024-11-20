CREATE MIGRATION m1z3obsy2rb7cybmhrwa4tvmtapemgsaw3fghbrlsg2atifevfrouq
    ONTO m1t6kecldtl2nuk263giobem3fmuiyz4vvkz2tarzheibo4p42vcgq
{
  ALTER TYPE default::Primitive {
      ALTER LINK projects {
          RESET OPTIONALITY;
      };
  };
  ALTER TYPE default::Organization {
      CREATE REQUIRED PROPERTY componentLength: std::int32 {
          SET default := 4;
      };
      CREATE REQUIRED PROPERTY revisionLength: std::int32 {
          SET default := 1;
      };
      CREATE REQUIRED PROPERTY unitLength: std::int32 {
          SET default := 5;
      };
  };
  ALTER TYPE design::Component {
      ALTER LINK organization {
          SET default := ((GLOBAL default::userCurrent).organization);
          SET readonly := true;
          SET OWNED;
          SET TYPE default::Organization;
      };
      CREATE ACCESS POLICY IAllowUserToSelectAndInsertUsersFromTheSameOrganization
          ALLOW SELECT, INSERT USING ((((GLOBAL default::userCurrent).organization ?= .organization) ?? false));
      CREATE PROPERTY identifier: std::str;
      CREATE CONSTRAINT std::exclusive ON ((.identifier, .organization));
      ALTER LINK projects {
          RESET OPTIONALITY;
      };
  };
};
