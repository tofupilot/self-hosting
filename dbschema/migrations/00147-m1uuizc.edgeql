CREATE MIGRATION m1uuizccaxev4ylmmwqxqffvked6nj34xepgnh23pg4h67bulbbnja
    ONTO m1oca45f422ruxssjo3ath47mxwg2u2o3ae5fii5saos2wrtt3zrha
{
  ALTER TYPE design::DesignInstance {
      ALTER LINK organization {
          SET default := ((GLOBAL default::userCurrent).organization);
          SET readonly := true;
          SET OWNED;
          SET TYPE default::Organization;
      };
      CREATE ACCESS POLICY IAllowUserToSelectAndInsertUsersFromTheSameOrganization
          ALLOW SELECT, INSERT USING ((((GLOBAL default::userCurrent).organization = .organization) ?? false));
  };
};
