CREATE MIGRATION m1bitw5p6rta3vnh36bogzxjmxute556hxcbaxnumwyd2inti3apia
    ONTO m1lfn7edwu5yxqctihj3tkdh75b2gi6lqvntn5c4roa5mwg7bmpctq
{
  CREATE ABSTRACT TYPE default::PrimitiveProperty {
      CREATE LINK organization -> default::Organization {
          SET default := ((GLOBAL default::currentUser).organization);
          SET readonly := true;
      };
      CREATE LINK createdBy -> default::User {
          SET default := (SELECT
              default::User
          FILTER
              (.id = GLOBAL default::currentUserId)
          );
          SET readonly := true;
      };
      CREATE PROPERTY createdAt -> std::datetime {
          SET default := (std::datetime_of_statement());
          SET readonly := true;
      };
      CREATE ACCESS POLICY IAllowOrgMemberToDoAnything
          ALLOW ALL USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
      CREATE ACCESS POLICY IAllowSuperAdminToSelectForAnalytics
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  ALTER TYPE default::Project {
      EXTENDING default::PrimitiveProperty LAST;
      ALTER LINK organization {
          DROP OWNED;
          RESET TYPE;
      };
  };
  ALTER TYPE default::Project {
      ALTER LINK createdBy {
          DROP OWNED;
          RESET TYPE;
      };
      ALTER PROPERTY createdAt {
          DROP OWNED;
          RESET TYPE;
      };
  };
  ALTER TYPE default::Primitive {
      ALTER ACCESS POLICY IAllowOrgMemberToDoEveryting RENAME TO IAllowOrgMemberToDoAnything;
  };
  ALTER TYPE default::Primitive {
      ALTER ACCESS POLICY IAllowSuperAdminToSelect RENAME TO IAllowSuperAdminToSelectForAnalytics;
  };
  ALTER TYPE default::Label {
      EXTENDING default::PrimitiveProperty LAST;
      ALTER LINK organization {
          DROP OWNED;
          RESET TYPE;
      };
      ALTER LINK createdBy {
          DROP OWNED;
          RESET TYPE;
      };
      ALTER PROPERTY createdAt {
          DROP OWNED;
          RESET TYPE;
      };
  };
  ALTER TYPE default::Status {
      EXTENDING default::PrimitiveProperty LAST;
      ALTER LINK organization {
          DROP OWNED;
          RESET TYPE;
      };
      ALTER LINK createdBy {
          DROP OWNED;
          RESET TYPE;
      };
      ALTER PROPERTY createdAt {
          DROP OWNED;
          RESET TYPE;
      };
  };
};
