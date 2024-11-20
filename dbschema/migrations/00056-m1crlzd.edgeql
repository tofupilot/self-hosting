CREATE MIGRATION m1crlzdm5754yxzrlbe5xee23re2m3ucp2p5vutxug3m4eb25ez4aa
    ONTO m1auehtulrbidqr63rtjgvyw3llo42bqlkynssn6ulvlah6iaolmxa
{
  ALTER TYPE activity::Activity {
      DROP ACCESS POLICY access_own_activity;
  };
  ALTER TYPE activity::Activity {
      CREATE ACCESS POLICY insert_own_activity
          ALLOW INSERT USING ((GLOBAL default::currentUserId ?= .actor.id));
  };
  ALTER TYPE activity::LabelChange {
      CREATE ACCESS POLICY select_if_in_same_org_as_primitive
          ALLOW SELECT USING (((GLOBAL default::currentUser IN .primitive.organization.users) ?? false));
  };
  ALTER TYPE activity::OwnerChange {
      CREATE ACCESS POLICY select_if_in_same_org_as_primitive
          ALLOW SELECT USING (((GLOBAL default::currentUser IN .primitive.organization.users) ?? false));
  };
  ALTER TYPE activity::StatusChange {
      CREATE ACCESS POLICY select_if_in_same_org_as_primitive
          ALLOW SELECT USING (((GLOBAL default::currentUser IN .primitive.organization.users) ?? false));
  };
};
