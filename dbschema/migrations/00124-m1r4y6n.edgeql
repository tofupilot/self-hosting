CREATE MIGRATION m1r4y6ncylyk4o6wo64yaleimim3c5wy2genc73bgjvvuel2hctdba
    ONTO m1fdsdum2pwbtbpn2fouu4ylfclcw3gwqi2eo6gzuj3xhuwqr4z67q
{
  ALTER TYPE relation::Relation {
      CREATE ACCESS POLICY IAllowSuperAdminToSelectForAnalytics
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
};
