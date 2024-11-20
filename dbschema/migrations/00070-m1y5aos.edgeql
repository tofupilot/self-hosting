CREATE MIGRATION m1y5aosuqqorsx2yegokqvvbcirjmqs7lma7xhgyhpc6t23gxy35eq
    ONTO m1l5hzgdao2t4uxzowzktifudmkxalsgvuz6yflpmbscucqlzxzeqa
{
  CREATE MODULE release IF NOT EXISTS;
  ALTER TYPE default::User {
      ALTER PROPERTY superAdmin {
          RESET readonly;
      };
  };
  ALTER TYPE activity::Activity {
      ALTER ACCESS POLICY insert_own_activity RENAME TO IAllowUserToInsertItsActivity;
  };
  ALTER TYPE activity::Activity {
      ALTER ACCESS POLICY super_admin_access RENAME TO IAllowSuperAdminToSelectForAnalytics;
  };
  ALTER TYPE default::Label {
      ALTER PROPERTY name {
          CREATE CONSTRAINT std::min_len_value(1);
      };
  };
  ALTER TYPE default::Organization {
      ALTER PROPERTY name {
          CREATE CONSTRAINT std::min_len_value(1);
      };
  };
  ALTER TYPE default::Project {
      ALTER PROPERTY name {
          CREATE CONSTRAINT std::min_len_value(1);
      };
  };
  ALTER TYPE default::User {
      CREATE PROPERTY firstName := ((std::str_split(.name, ' '))[0]);
      ALTER PROPERTY name {
          DROP CONSTRAINT std::max_len_value(50);
      };
  };
  CREATE ABSTRACT TYPE release::Permissions {
      CREATE ACCESS POLICY IAllowPublicSelect
          ALLOW SELECT USING (true);
      CREATE ACCESS POLICY IAllowSuperAdminCRUD
          ALLOW ALL USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  CREATE SCALAR TYPE release::HighlightCategory EXTENDING enum<Feature, Design, Improvement>;
  CREATE TYPE release::Highlight EXTENDING release::Permissions {
      CREATE MULTI PROPERTY category -> release::HighlightCategory;
      CREATE PROPERTY content -> std::json;
      CREATE PROPERTY imageUrl -> std::str;
  };
  CREATE TYPE release::Release EXTENDING release::Permissions {
      CREATE PROPERTY content -> std::json;
      CREATE REQUIRED PROPERTY date -> std::datetime {
          SET default := (std::datetime_of_statement());
      };
      CREATE REQUIRED PROPERTY version -> std::str {
          CREATE CONSTRAINT std::regexp(r'^\d+\.\d+\.\d+$');
      };
  };
  ALTER TYPE release::Highlight {
      CREATE REQUIRED LINK release -> release::Release;
  };
  ALTER TYPE release::Release {
      CREATE MULTI LINK highlights := (.<release[IS release::Highlight]);
  };
};
