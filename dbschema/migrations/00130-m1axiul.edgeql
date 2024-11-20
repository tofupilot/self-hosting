CREATE MIGRATION m1axiulorkbpuaocwso4crukf5akrugpl2q5ucjyjhyc6cnrl2jeiq
    ONTO m1hwu4nonwqqa2cmph6dhb57i6gvemlpocvl3ahoesyit6ahmx5sza
{
  ALTER TYPE activity::PrimitivePropertyChange {
      ALTER ACCESS POLICY IAllowIfUserInSameOrganizationThanPrimitive RENAME TO IAllowSelectUpdateIfUserInSameOrganizationThanPrimitive;
  };
  ALTER TYPE activity::PrimitivePropertyChange {
      ALTER ACCESS POLICY IAllowSelectUpdateIfUserInSameOrganizationThanPrimitive USING ((((GLOBAL default::currentUser).organization ?= .primitive.organization) ?? false));
  };
  ALTER TYPE default::PrimitiveProperty {
      ALTER ACCESS POLICY IAllowOrgMemberToDoAnything USING ((((GLOBAL default::currentUser).organization ?= .organization) ?? false));
  };
  ALTER TYPE default::Primitive {
      ALTER ACCESS POLICY IAllowOrgMemberToDoAnything USING ((((GLOBAL default::currentUser).organization ?= .organization) ?? false));
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY IAllowUserToSelectOrganizationsHeCreated USING (((GLOBAL default::currentUser ?= .createdBy) ?? false));
      ALTER ACCESS POLICY IAllowUserToSelectOrganizationsHeIsMemberOff USING ((((GLOBAL default::currentUser).organization.id ?= .id) ?? false));
  };
  ALTER TYPE default::User {
      ALTER ACCESS POLICY IAllowUserToSelectAndInsertUsersFromTheSameOrganization USING ((((GLOBAL default::currentUser).organization ?= .organization) ?? false));
  };
};
