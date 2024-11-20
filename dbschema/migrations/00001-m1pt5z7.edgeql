CREATE MIGRATION m1pt5z7pohseqt7scexs7jhl4zz52ecacppg3jms5nd6t5dc2tfula
    ONTO initial
{
  CREATE FUTURE nonrecursive_access_policies;
  CREATE GLOBAL default::currentUserId -> std::uuid;
  CREATE TYPE default::User {
      CREATE PROPERTY createdAt -> std::datetime {
          SET default := (std::datetime_of_statement());
          SET readonly := true;
      };
      CREATE REQUIRED PROPERTY email -> std::str {
          CREATE CONSTRAINT std::exclusive;
      };
      CREATE PROPERTY emailVerified -> std::datetime;
      CREATE PROPERTY image -> std::str;
      CREATE PROPERTY name -> std::str;
      CREATE PROPERTY superAdmin -> std::bool {
          SET default := false;
      };
      CREATE ACCESS POLICY server_can_list_and_insert
          ALLOW SELECT, INSERT USING (NOT (EXISTS (GLOBAL default::currentUserId)));
      CREATE ACCESS POLICY update_own_data
          ALLOW UPDATE USING ((GLOBAL default::currentUserId ?= .id));
  };
  CREATE GLOBAL default::currentUser := (SELECT
      default::User
  FILTER
      (.id = GLOBAL default::currentUserId)
  );
  CREATE ABSTRACT TYPE default::Primitive {
      CREATE LINK assignee -> default::User;
      CREATE MULTI LINK links -> default::Primitive;
      CREATE MULTI LINK backlinks := (.<links[IS default::Primitive]);
      CREATE LINK parent -> default::Primitive {
          ON TARGET DELETE ALLOW;
      };
      CREATE MULTI LINK children := (.<parent[IS default::Primitive]);
      CREATE PROPERTY content -> std::json;
      CREATE REQUIRED PROPERTY name -> std::str;
  };
  CREATE TYPE default::Action EXTENDING default::Primitive;
  CREATE TYPE default::Organization {
      CREATE ACCESS POLICY server_can_list_and_insert
          ALLOW SELECT USING (NOT (EXISTS (GLOBAL default::currentUserId)));
      CREATE REQUIRED PROPERTY name -> std::str;
  };
  ALTER TYPE default::User {
      CREATE LINK organization -> default::Organization {
          ON TARGET DELETE ALLOW;
          CREATE CONSTRAINT std::exclusive;
      };
  };
  ALTER TYPE default::Organization {
      CREATE MULTI LINK users := (.<organization[IS default::User]);
      CREATE ACCESS POLICY same_organization
          ALLOW SELECT USING (((GLOBAL default::currentUser IN .users) ?? false));
      CREATE ACCESS POLICY super_admin_access
          ALLOW ALL USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  ALTER TYPE default::Primitive {
      CREATE LINK organization -> default::Organization {
          SET default := ((GLOBAL default::currentUser).organization);
          SET readonly := true;
      };
      CREATE ACCESS POLICY org_members_have_full_access
          ALLOW ALL USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
  };
  CREATE SCALAR TYPE default::LabelColor EXTENDING enum<Gray, Red, Yellow, Green, Blue, Indigo, Purple, Pink>;
  CREATE SCALAR TYPE default::PrimitiveNamespace EXTENDING enum<Product, Requirement, Issue, Action>;
  CREATE TYPE default::Label {
      CREATE LINK organization -> default::Organization {
          SET default := ((GLOBAL default::currentUser).organization);
          SET readonly := true;
      };
      CREATE ACCESS POLICY org_members_have_full_access
          ALLOW ALL USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
      CREATE ACCESS POLICY super_admin_have_full_acess
          ALLOW ALL USING (((GLOBAL default::currentUser).superAdmin ?? false));
      CREATE REQUIRED PROPERTY color -> default::LabelColor;
      CREATE REQUIRED PROPERTY name -> std::str;
      CREATE REQUIRED PROPERTY primitive -> default::PrimitiveNamespace;
  };
  ALTER TYPE default::Primitive {
      CREATE MULTI LINK labels -> default::Label;
  };
  CREATE TYPE default::Project {
      CREATE LINK organization -> default::Organization {
          SET default := ((GLOBAL default::currentUser).organization);
          SET readonly := true;
      };
      CREATE ACCESS POLICY org_members_have_full_access
          ALLOW ALL USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
      CREATE ACCESS POLICY super_admin_have_full_acess
          ALLOW ALL USING (((GLOBAL default::currentUser).superAdmin ?? false));
      CREATE REQUIRED PROPERTY name -> std::str;
  };
  ALTER TYPE default::Primitive {
      CREATE REQUIRED MULTI LINK projects -> default::Project;
  };
  CREATE SCALAR TYPE default::StatusCategory EXTENDING enum<Pending, Ongoing, Successful, Unsuccessful>;
  CREATE TYPE default::Status {
      CREATE LINK organization -> default::Organization {
          SET default := ((GLOBAL default::currentUser).organization);
          SET readonly := true;
      };
      CREATE ACCESS POLICY org_members_have_full_access
          ALLOW ALL USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
      CREATE ACCESS POLICY super_admin_have_full_acess
          ALLOW ALL USING (((GLOBAL default::currentUser).superAdmin ?? false));
      CREATE REQUIRED PROPERTY category -> default::StatusCategory;
      CREATE REQUIRED PROPERTY name -> std::str;
      CREATE REQUIRED PROPERTY primitive -> default::PrimitiveNamespace;
  };
  ALTER TYPE default::Primitive {
      CREATE LINK status -> default::Status;
      CREATE ACCESS POLICY super_admin_have_full_acess
          ALLOW ALL USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  CREATE TYPE default::Issue EXTENDING default::Primitive;
  CREATE TYPE default::Product EXTENDING default::Primitive;
  CREATE TYPE default::Requirement EXTENDING default::Primitive;
  ALTER TYPE default::User {
      CREATE ACCESS POLICY same_organization
          ALLOW SELECT USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
      CREATE ACCESS POLICY super_admin_access
          ALLOW ALL USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  CREATE TYPE default::Account {
      CREATE REQUIRED LINK user -> default::User {
          ON TARGET DELETE DELETE SOURCE;
      };
      CREATE REQUIRED PROPERTY userId := (.user.id);
      CREATE REQUIRED PROPERTY provider -> std::str;
      CREATE REQUIRED PROPERTY providerAccountId -> std::str {
          CREATE CONSTRAINT std::exclusive;
      };
      CREATE CONSTRAINT std::exclusive ON ((.provider, .providerAccountId));
      CREATE PROPERTY access_token -> std::str;
      CREATE PROPERTY createdAt -> std::datetime {
          SET default := (std::datetime_of_statement());
          SET readonly := true;
      };
      CREATE PROPERTY expires_at -> std::int64;
      CREATE PROPERTY id_token -> std::str;
      CREATE PROPERTY refresh_token -> std::str;
      CREATE PROPERTY scope -> std::str;
      CREATE PROPERTY session_state -> std::str;
      CREATE PROPERTY token_type -> std::str;
      CREATE REQUIRED PROPERTY type -> std::str;
  };
  CREATE TYPE default::Session {
      CREATE REQUIRED LINK user -> default::User {
          ON TARGET DELETE DELETE SOURCE;
      };
      CREATE REQUIRED PROPERTY userId := (.user.id);
      CREATE PROPERTY createdAt -> std::datetime {
          SET default := (std::datetime_current());
      };
      CREATE REQUIRED PROPERTY expires -> std::datetime;
      CREATE REQUIRED PROPERTY sessionToken -> std::str {
          CREATE CONSTRAINT std::exclusive;
      };
  };
  ALTER TYPE default::User {
      CREATE MULTI LINK accounts := (.<user[IS default::Account]);
      CREATE MULTI LINK sessions := (.<user[IS default::Session]);
  };
  CREATE TYPE default::VerificationToken {
      CREATE REQUIRED PROPERTY identifier -> std::str;
      CREATE REQUIRED PROPERTY token -> std::str {
          CREATE CONSTRAINT std::exclusive;
      };
      CREATE CONSTRAINT std::exclusive ON ((.identifier, .token));
      CREATE PROPERTY createdAt -> std::datetime {
          SET default := (std::datetime_of_statement());
          SET readonly := true;
      };
      CREATE REQUIRED PROPERTY expires -> std::datetime;
  };
};
