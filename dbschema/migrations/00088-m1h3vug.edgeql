CREATE MIGRATION m1h3vugwwnullx26k2wa4kttcwvcsiimjgwismezta2eeqxwcj4mfq
    ONTO m17g6ggkmihhpt2ryon3so2djgjngrk3rcgz7agvr5xmnf7ni7at5q
{
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY IAllowCurrentUserToSelectItsOwnOrganization RENAME TO IAllowUserToSelectOrganizationsHeIsMemberOff;
  };
  ALTER TYPE default::Organization {
      ALTER ACCESS POLICY IAllowServerToSelectAndInsertOrganizations RENAME TO IAllowServerToSelectOrganizationsForMiddlewareCheck;
  };
  ALTER TYPE default::Organization {
      CREATE ACCESS POLICY IAllowSignedInUserToInsertNewOrganization
          ALLOW INSERT USING (EXISTS (GLOBAL default::currentUserId));
  };
  ALTER TYPE default::Organization {
      CREATE ACCESS POLICY IAllowSuperAdminToSelectAllOrganizationsForAnalytics
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
  ALTER TYPE default::Organization {
      DROP ACCESS POLICY IAllowSuperAdminToSelectInsertAndDeleteOrganizations;
      CREATE LINK createdBy -> default::User {
          SET readonly := true;
      };
  };
  ALTER TYPE default::Organization {
      CREATE ACCESS POLICY IAllowUserToSelectOrganizationsHeCreated
          ALLOW SELECT USING (((GLOBAL default::currentUser = .createdBy) ?? false));
  };
  ALTER TYPE default::Organization {
      DROP ACCESS POLICY IAllowUsersToSelectAndInsertOrganizations;
  };
};
