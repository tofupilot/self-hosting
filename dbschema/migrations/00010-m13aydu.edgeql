CREATE MIGRATION m13ayduzkc5qgkgtzfbckxa5xe6h4jekj5siqahntpgnjnoh6fphza
    ONTO m16laanggafjia52trmuttzh74buhskzzv6h5bhtwr3elhf6o2qera
{
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY server_can_list RENAME TO server_can_select_insert_for_user_login_and_create_new_org_by_admin;
  };
  ALTER TYPE default::Organization {
      CREATE ACCESS POLICY server_can_select_for_user_signup
          ALLOW SELECT USING (EXISTS (GLOBAL default::currentUserId));
  };
};
