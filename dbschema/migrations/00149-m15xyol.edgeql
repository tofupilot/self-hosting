CREATE MIGRATION m15xyolwncvhlyelmhjlt3djlk4flgiom4m3phljjwywrfz7kzltva
    ONTO m1cdhhsxdlpwyp3zwbmpohdoviixg465iejwmlswmulbxx4u3ab7rq
{
  ALTER TYPE design::Component {
      CREATE ACCESS POLICY IAllowSuperAdminToSelectForAnalytics
          ALLOW SELECT USING (((GLOBAL default::userCurrent).superAdmin ?? false));
  };
  ALTER TYPE design::DesignInstance {
      CREATE ACCESS POLICY IAllowSuperAdminToSelectForAnalytics
          ALLOW SELECT USING (((GLOBAL default::userCurrent).superAdmin ?? false));
  };
};
