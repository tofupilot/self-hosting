CREATE MIGRATION m1okwdayaynw454gcasmq7rtkpinejo3ytqk2frbp3lwwmvs5ijpea
    ONTO m1skwjlpqbo3et44mmirqbufkq26xu5nbwjsf5bvjr5rwip55ndovq
{
  ALTER TYPE default::PrimitiveProperty {
      DROP ACCESS POLICY IAllowSuperAdminToSelectForAnalytics;
  };
  ALTER TYPE default::Organization {
      DROP ACCESS POLICY IAllowSuperAdminToSelectAllOrganizationsForAnalyticsAndUpdateThem;
  };
  ALTER TYPE default::User {
      DROP ACCESS POLICY IAllowSuperAdminUsersToSelectAndDeleteUsers;
  };
};
