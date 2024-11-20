CREATE MIGRATION m1yu5rcjdxtovqndrob3zoeikvji3i7s7chgfsdjmwjlo7cimrluva
    ONTO m16l7tq2svxymw675xho2pyaiz232pjwn7eb4d3bhl7jwkqcovrvoq
{
  ALTER TYPE default::Organization {
      CREATE MULTI LINK users := (.<organization[IS default::User]);
      CREATE ACCESS POLICY same_organization
          ALLOW SELECT USING (((GLOBAL default::currentUser IN .users) ?? false));
  };
  ALTER TYPE default::Primitive {
      CREATE ACCESS POLICY org_members_have_full_access
          ALLOW ALL USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
  };
  ALTER TYPE default::Label {
      CREATE ACCESS POLICY org_members_have_full_access
          ALLOW ALL USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
  };
  ALTER TYPE default::Project {
      CREATE ACCESS POLICY org_members_have_full_access
          ALLOW ALL USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
  };
  ALTER TYPE default::Status {
      CREATE ACCESS POLICY org_members_have_full_access
          ALLOW ALL USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
  };
  ALTER TYPE default::User {
      CREATE ACCESS POLICY same_organization
          ALLOW SELECT USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
  };
};
