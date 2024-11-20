CREATE MIGRATION m1l5hzgdao2t4uxzowzktifudmkxalsgvuz6yflpmbscucqlzxzeqa
    ONTO m1y7pdpjj2dj52p3vcvtctn2e5ov2tkbiy7gjr2m7oyoostewjacqq
{
  ALTER TYPE default::Primitive {
      ALTER ACCESS POLICY IAllowOrgMemberToDoAnything USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
  };
};
