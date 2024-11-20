CREATE MIGRATION m1v32iq23cd5qor3slmkk2me4qz6k4tlk3v3y5wmrfinhxxxqvtqfa
    ONTO m1x7rrwqzdqemvadjk6fzq37gfsfd7p6tmqepteyvzkkxufqtco5va
{
  ALTER TYPE activity::Activity {
      CREATE ACCESS POLICY super_admin_access
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
};
