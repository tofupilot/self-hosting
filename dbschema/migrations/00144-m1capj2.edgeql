CREATE MIGRATION m1capj2zg2huhflizo62mtvli5eclmikvdvojfuf75qmmja5z2hnwq
    ONTO m1z3obsy2rb7cybmhrwa4tvmtapemgsaw3fghbrlsg2atifevfrouq
{
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY IAllowUserToSelectOrganizationsHeIsMemberOff ALLOW SELECT, UPDATE;
  };
};
