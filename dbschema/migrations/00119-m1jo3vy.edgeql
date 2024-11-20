CREATE MIGRATION m1jo3vyw7vvj6rrpxvhgosfv7r3hkmn7bn2kbse6dqlldoo356rj2q
    ONTO m145uhzmfv33olzzojsi3j72epvmzq2d4234eyxvbbmmpjfichoc6q
{
  ALTER TYPE default::Organization {
      CREATE ACCESS POLICY IAllowSuperAdminToSelectOrganizationForAnalytics
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
};
