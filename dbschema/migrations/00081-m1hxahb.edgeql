CREATE MIGRATION m1hxahbwktbqrdk62rw2wlsntbxmijo7bkqf52oq2zejppm7amre4q
    ONTO m1gs2o5gphmkldlacrs7xnniznd3z3q645pg4opekqs7iqpmviyota
{
  ALTER TYPE default::Primitive {
      CREATE ACCESS POLICY IAllowSuperAdminToSelectForAnalytics
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
      CREATE MULTI LINK labelChanges := (.<primitive[IS activity::LabelChange]);
      CREATE MULTI LINK ownerChanges := (.<primitive[IS activity::OwnerChange]);
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY same_organization RENAME TO IAllowCurrentUserToSelectItsOwnOrganization;
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY server_can_select_for_user_signup RENAME TO IAllowServerToSelectAndInsertOrganizations;
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY IAllowServerToSelectAndInsertOrganizations USING (NOT (EXISTS (GLOBAL default::currentUserId)));
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY server_can_select_insert_for_user_login_and_create_new_org_by_admin RENAME TO IAllowUsersToSelectAndInsertOrganizations;
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY IAllowUsersToSelectAndInsertOrganizations USING (EXISTS (GLOBAL default::currentUserId));
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY super_admin_access RENAME TO IAllowSuperAdminToSelectInsertAndDeleteOrganizations;
  };
  ALTER TYPE default::User {
      CREATE ACCESS POLICY IAllowUserToSelectAndInsertUsersFromTheSameOrganization
          ALLOW SELECT, INSERT USING (((GLOBAL default::currentUser IN .organization.users) ?? false));
  };
  ALTER TYPE default::User {
      DROP ACCESS POLICY same_organization;
  };
  ALTER TYPE default::User {
      ALTER ACCESS POLICY server_can_list_and_insert RENAME TO IAllowServerToSelectInsertAndUpdateUsers;
  };
  ALTER TYPE default::User {
      ALTER ACCESS POLICY super_admin_access RENAME TO IAllowSuperAdminUsersToSelectAndDeleteUsers;
  };
  ALTER TYPE default::User {
      ALTER ACCESS POLICY update_own_data RENAME TO IGiveFullReadWriteAccessToUserRegardingItsOwnData;
  };
};
