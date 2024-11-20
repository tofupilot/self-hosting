CREATE MIGRATION m1xugxgnhvwnxyngpilgosvy6afi7tuww3mtli66ciexq44cr6crjq
    ONTO m1v32iq23cd5qor3slmkk2me4qz6k4tlk3v3y5wmrfinhxxxqvtqfa
{
  ALTER TYPE default::Primitive {
      ALTER ACCESS POLICY org_members_have_full_access USING ((((GLOBAL default::currentUser IN .organization.users) ?? false) AND (((GLOBAL default::currentUser).organization IN .projects.organization) ?? false)));
  };
  ALTER TYPE default::Primitive {
      CREATE ACCESS POLICY super_admin
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  ALTER TYPE default::Primitive {
      DROP ACCESS POLICY super_admin_have_full_acess;
  };
  ALTER TYPE default::Label {
      CREATE ACCESS POLICY super_admin_can_read_for_analytics
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  ALTER TYPE default::Label {
      DROP ACCESS POLICY super_admin_have_full_acess;
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY super_admin_access ALLOW SELECT, INSERT;
  };
  ALTER TYPE default::Project {
      CREATE ACCESS POLICY super_admin_can_read_for_analytics
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  ALTER TYPE default::Project {
      DROP ACCESS POLICY super_admin_have_full_acess;
  };
  ALTER TYPE default::Status {
      CREATE ACCESS POLICY super_admin_can_read_for_analytics
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  ALTER TYPE default::Status {
      DROP ACCESS POLICY super_admin_have_full_acess;
  };
  ALTER TYPE default::Upload {
      CREATE ACCESS POLICY super_admin_can_read_for_analytics
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  ALTER TYPE default::Upload {
      DROP ACCESS POLICY super_admin_have_full_acess;
  };
  ALTER TYPE default::User {
      ALTER ACCESS POLICY super_admin_access ALLOW SELECT;
  };
};
