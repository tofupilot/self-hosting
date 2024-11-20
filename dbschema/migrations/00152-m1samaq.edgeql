CREATE MIGRATION m1samaqfgxss7osdvl3cfbtcbsnmnqvzdbu5afbut2lso3zccrf44q
    ONTO m1ea4g7fzh2prx4wqnsdfl3vz76gitpavzilsepbi5eq6hmeixqg6a
{
  ALTER TYPE default::User {
      DROP ACCESS POLICY IAllowUserToSelectAndInsertUsersFromTheSameOrganization;
  };
  ALTER TYPE default::User {
      CREATE ACCESS POLICY IAllowUserToSelectInsertAndUpdateUsersFromTheSameOrganization
          ALLOW SELECT, UPDATE, INSERT USING ((((GLOBAL default::userCurrent).organization = .organization) ?? false));
  };
};
