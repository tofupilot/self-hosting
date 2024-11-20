CREATE MIGRATION m1vakqu44k2lrqem7m2sn4tgjj4sxfms3zxsxv2qsepk5eexok757a
    ONTO m1jzrrge3jemkinctlacnpobp3bm64toh2wwhi33zc4g4enwxwp7da
{
  CREATE TYPE default::Upload {
      CREATE LINK organization -> default::Organization {
          SET default := ((GLOBAL default::currentUser).organization);
          SET readonly := true;
      };
      CREATE ACCESS POLICY org_members_have_full_access
          ALLOW ALL USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
      CREATE ACCESS POLICY super_admin_have_full_acess
          ALLOW ALL USING (((GLOBAL default::currentUser).superAdmin ?? false));
      CREATE LINK createdBy -> default::User {
          SET default := (SELECT
              default::User
          FILTER
              (.id = GLOBAL default::currentUserId)
          );
          SET readonly := true;
      };
      CREATE REQUIRED PROPERTY content_type -> std::str;
      CREATE PROPERTY createdAt -> std::datetime {
          SET default := (std::datetime_of_statement());
          SET readonly := true;
      };
      CREATE REQUIRED PROPERTY etag -> std::str;
      CREATE REQUIRED PROPERTY name -> std::str;
      CREATE REQUIRED PROPERTY size -> std::int64;
  };
};
