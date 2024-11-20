CREATE MIGRATION m1y7pdpjj2dj52p3vcvtctn2e5ov2tkbiy7gjr2m7oyoostewjacqq
    ONTO m1o42ohzfqfa7vzqgslnjve3vm75xv5w2op7e3ig7fo3oz5knodt5q
{
  ALTER TYPE default::Primitive {
      DROP ACCESS POLICY IAllowSuperAdminToSelectForAnalytics;
  };
};
