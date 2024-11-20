CREATE MIGRATION m16l7tq2svxymw675xho2pyaiz232pjwn7eb4d3bhl7jwkqcovrvoq
    ONTO m1d4hc7zngpnsere6t2xz3ml6l7rmjjqxxchuhlfqdachv3ywkblva
{
  ALTER TYPE default::Primitive {
      DROP ACCESS POLICY org_members_have_full_access;
  };
  ALTER TYPE default::Label {
      DROP ACCESS POLICY org_members_have_full_access;
  };
  ALTER TYPE default::Organization {
      DROP ACCESS POLICY same_organization;
  };
  ALTER TYPE default::Project {
      DROP ACCESS POLICY org_members_have_full_access;
  };
  ALTER TYPE default::Status {
      DROP ACCESS POLICY org_members_have_full_access;
  };
  ALTER TYPE default::User {
      DROP ACCESS POLICY same_organization;
      ALTER LINK organization {
          RESET ON TARGET DELETE;
          DROP CONSTRAINT std::exclusive;
      };
  };
  ALTER TYPE default::Organization {
      DROP LINK users;
  };
};
