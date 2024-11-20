CREATE MIGRATION m1rszu4dkd22atmptlq4jndqqolp2x6x4o5a4tugn365rxghufetuq
    ONTO m1fhnhnhjakgevu7z4axnxxdwuzzvriv7wz4uzjrl5n64bza4mimuq
{
  ALTER TYPE default::Primitive {
      ALTER ACCESS POLICY org_members_have_full_access USING ((((GLOBAL default::currentUser IN .organization.users) AND ((GLOBAL default::currentUser).organization IN .projects.organization)) ?? false));
  };
};
