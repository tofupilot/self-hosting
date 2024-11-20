CREATE MIGRATION m16laanggafjia52trmuttzh74buhskzzv6h5bhtwr3elhf6o2qera
    ONTO m1yu5rcjdxtovqndrob3zoeikvji3i7s7chgfsdjmwjlo7cimrluva
{
  ALTER TYPE default::Organization {
      DROP ACCESS POLICY server_can_list2;
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY server_can_list ALLOW SELECT, INSERT;
  };
};
