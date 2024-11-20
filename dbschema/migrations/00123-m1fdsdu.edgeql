CREATE MIGRATION m1fdsdum2pwbtbpn2fouu4ylfclcw3gwqi2eo6gzuj3xhuwqr4z67q
    ONTO m1kpedybcl6ej6ebtxmekusm47kswlhcyubzat66ibfywgu5w6v2va
{
  ALTER TYPE default::Primitive {
      DROP ACCESS POLICY IAllowSuperAdminToSelectForAnalytics;
  };
  ALTER TYPE default::Primitive {
      CREATE ACCESS POLICY IAllowSuperAdminToSelectForAnalyticsAndUpdateForMigrations
          ALLOW SELECT, UPDATE USING (((GLOBAL default::currentUser).superAdmin ?? false));
      CREATE PROPERTY identifier: std::str;
      CREATE CONSTRAINT std::exclusive ON ((.identifier, .organization));
  };
};
