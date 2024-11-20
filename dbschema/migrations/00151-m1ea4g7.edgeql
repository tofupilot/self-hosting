CREATE MIGRATION m1ea4g7fzh2prx4wqnsdfl3vz76gitpavzilsepbi5eq6hmeixqg6a
    ONTO m1cjzaqiohmfc5ncuayjmnk3ocmn2g7dwrmfchorf5ipftmngtuqma
{
  ALTER TYPE default::User {
      CREATE PROPERTY archivedAt: std::datetime;
  };
};
